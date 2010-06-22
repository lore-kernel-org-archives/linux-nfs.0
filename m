From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 1/1] nfs-iostat.py: divide by zero with fresh mount
Date: Tue, 22 Jun 2010 17:52:09 -0400
Message-ID: <4C213089.5090008@RedHat.com>
References: <4C06913A.7090608@disney.com> <1275950427-10200-1-git-send-email-kevin.constantine@disneyanimation.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org,
	Kevin Constantine <Kevin.Constantine-P5ys19MLBK/QT0dZR+AlfA@public.gmane.org>
To: Kevin Constantine <Kevin.Constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43325 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750938Ab0FVVw3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Jun 2010 17:52:29 -0400
In-Reply-To: <1275950427-10200-1-git-send-email-kevin.constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/07/2010 06:40 PM, Kevin Constantine wrote:
> When an export is freshly mounted, /proc/self/mountstats displays age = 0.
> This causes nfs-iostat.py to divide by zero throwing an error.  When we
> have age = 0, other stats are greater than 0, so we'll set age = 1 and
> print the relevant stats.
> 
> Signed-off-by: Kevin Constantine <kevin.constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
> ---
>  tools/nfs-iostat/nfs-iostat.py |    6 ++++++
>  1 files changed, 6 insertions(+), 0 deletions(-)
> 
> diff --git a/tools/nfs-iostat/nfs-iostat.py b/tools/nfs-iostat/nfs-iostat.py
> index 2d0b143..1207674 100644
> --- a/tools/nfs-iostat/nfs-iostat.py
> +++ b/tools/nfs-iostat/nfs-iostat.py
> @@ -366,6 +366,12 @@ class DeviceData:
>          sends = float(self.__rpc_data['rpcsends'])
>          if sample_time == 0:
>              sample_time = float(self.__nfs_data['age'])
> +        #  sample_time could still be zero if the export was just mounted.
> +        #  Set it to 1 to avoid divide by zero errors in this case since we'll
> +        #  likely still have relevant mount statistics to show.
> +        #
> +        if sample_time == 0:
> +            sample_time = 1;
>          if sends != 0:
>              backlog = (float(self.__rpc_data['backlogutil']) / sends) / sample_time
>          else:
Committed.. 

steved.
