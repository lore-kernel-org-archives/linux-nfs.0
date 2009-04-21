From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 2/2] nfs-iostat.py: Added bytes written output
Date: Tue, 21 Apr 2009 10:26:01 -0400
Message-ID: <ABA1CFF5-7104-4ADD-9847-F6B9136D9987@oracle.com>
References: <1240279414-30528-1-git-send-email-kevin.constantine@disneyanimation.com> <1240279414-30528-2-git-send-email-kevin.constantine@disneyanimation.com> <1240279414-30528-3-git-send-email-kevin.constantine@disneyanimation.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org,
	Kevin Constantine <Kevin.Constantine-P5ys19MLBK/QT0dZR+AlfA@public.gmane.org>
To: Kevin Constantine <Kevin.Constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:41680 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754481AbZDUO0j (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Apr 2009 10:26:39 -0400
In-Reply-To: <1240279414-30528-3-git-send-email-kevin.constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 20, 2009, at 10:03 PM, Kevin Constantine wrote:
> Print statistics about bytes written by NFS
>
> Signed-off-by: Kevin Constantine <kevin.constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org 
> >
> ---
> tools/nfs-iostat/nfs-iostat.py |   10 ++++++++++
> 1 files changed, 10 insertions(+), 0 deletions(-)
>
> diff --git a/tools/nfs-iostat/nfs-iostat.py b/tools/nfs-iostat/nfs- 
> iostat.py
> index d331a72..5f2e232 100644
> --- a/tools/nfs-iostat/nfs-iostat.py
> +++ b/tools/nfs-iostat/nfs-iostat.py
> @@ -221,6 +221,7 @@ class DeviceData:
>         """
>         nfs_stats = self.__nfs_data
>         app_bytes_read = float(nfs_stats['normalreadbytes'] +  
> nfs_stats['directreadbytes'])
> +        bytes_written_by_app = float(nfs_stats['normalwritebytes']  
> + nfs_stats['directwritebytes'])
>         if app_bytes_read != 0:
>             read_bytes_from_server =  
> float(nfs_stats['serverreadbytes'])
>             directio_bytes_from_server =  
> float(nfs_stats['directreadbytes'])
> @@ -234,6 +235,15 @@ class DeviceData:
> 						cached_read_bytes / 1024.0 / 1024.0, \
> 						app_bytes_read / 1024.0 / 1024.0, \
> 						ratio)
> +	if bytes_written_by_app != 0:
> +	    bytes_written_by_nfs = float(nfs_stats['serverwritebytes'])
> +	    cached_write_bytes = float(bytes_written_by_app -  
> bytes_written_by_nfs);

Again, I don't see why this computation is necessary:  The  
"normalwritebytes" statistic is what was written through the client's  
cache, and "directwritebytes" counts the number of bytes that were  
written via O_DIRECT.

> +	    print
> +            print '%13s %12s %15s %15s' % ("Data Written:", "To  
> Server", "To Cache", "Total")
> +	    print '%10s %13.4fMB %13.4fMB %13.4fMB' % ("", \
> +	    					bytes_written_by_nfs / 1024.0 / 1024.0, \
> +						cached_write_bytes / 1024.0 / 1024.0, \
> +						bytes_written_by_app / 1024.0 / 1024.0)
>
>     def __print_attr_cache_stats(self, sample_time):
>         """Print attribute cache efficiency stats
> -- 
> 1.6.2.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




