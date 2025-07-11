using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using System;

[ApiController]
[Route("api/[controller]")]
public class DocumentsController : ControllerBase
{
    private readonly AzureBlobService _blobService;

    public DocumentsController(AzureBlobService blobService)
    {
        _blobService = blobService;
    }

    [HttpGet("ping")]
    public IActionResult Ping() => Ok("API is alive");

    [HttpPost("upload")]
    public async Task<IActionResult> Upload([FromForm] IFormFile file)
    {
        if (file == null || file.Length == 0)
            return BadRequest("File is required");

        using var stream = file.OpenReadStream();
        var url = await _blobService.UploadFileAsync(stream, file.FileName);
        return Ok(new { fileUrl = url });
    }

    [HttpGet("download/{fileName}")]
    public async Task<IActionResult> Download(string fileName)
    {
        try
        {
            var stream = await _blobService.DownloadFileAsync(fileName);
            return File(stream, "application/octet-stream", fileName);
        }
        catch
        {
            return NotFound("File not found");
        }
    }

    [HttpGet("list")]
    public async Task<IActionResult> List()
    {
        var files = await _blobService.ListAllFilesAsync();
        return Ok(files);
    }

    [HttpDelete("delete/{fileName}")]
    public async Task<IActionResult> Delete(string fileName)
    {
        var success = await _blobService.DeleteFileAsync(fileName);
        if (success) return Ok("File deleted");
        return NotFound("File not found");
    }
}
