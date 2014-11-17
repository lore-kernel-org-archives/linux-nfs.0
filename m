Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:34697 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751283AbaKQScH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Nov 2014 13:32:07 -0500
Message-ID: <546A3F22.8020001@RedHat.com>
Date: Mon, 17 Nov 2014 13:32:02 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] mountstats: Fix spurious I/O errors
References: <20141117162339.15387.88477.stgit@manet.1015granger.net>
In-Reply-To: <20141117162339.15387.88477.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/17/2014 11:23 AM, Chuck Lever wrote:
> When running mountstats under "watch," occassionally the output
> shows "close failed in file object desctructor: sys.excepthook is
> missing" and the data display is messed up. This seems to be a
> common problem when Python script output is piped to another
> program.
> 
> Ensure stdout/stderr is completely flushed before mountstats exits,
> and add an IOError exception handler to catch these exceptions
> gracefully.
> 
> Solution suggested by: http://bugs.python.org/issue11380
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Committed... 

steved.

> ---
>  tools/mountstats/mountstats.py |    4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
> index 9a6ec43..e6a456c 100644
> --- a/tools/mountstats/mountstats.py
> +++ b/tools/mountstats/mountstats.py
> @@ -612,8 +612,12 @@ try:
>          nfsstat_command()
>      elif prog == 'ms-iostat':
>          iostat_command()
> +    sys.stdout.close()
> +    sys.stderr.close()
>  except KeyboardInterrupt:
>      print('Caught ^C... exiting')
>      sys.exit(1)
> +except IOError:
> +    pass
>  
>  sys.exit(0)
> 
