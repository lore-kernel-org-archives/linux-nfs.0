Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34268 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751501AbdJEO4D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 5 Oct 2017 10:56:03 -0400
Subject: Re: [PATCH] nfsiostat: avoid parsing "no device mounted ..." line
To: Manjunath Patil <manjunath.b.patil@oracle.com>,
        linux-nfs@vger.kernel.org
Cc: mbpatil.linux@gmail.com
References: <1506112900-15638-1-git-send-email-manjunath.b.patil@oracle.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <b546bd8a-7356-0d68-6f38-21e4c5162509@RedHat.com>
Date: Thu, 5 Oct 2017 10:56:02 -0400
MIME-Version: 1.0
In-Reply-To: <1506112900-15638-1-git-send-email-manjunath.b.patil@oracle.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 09/22/2017 04:41 PM, Manjunath Patil wrote:
> Present nfsiostat includes the "no device mounted ..." line from
> /proc/self/mountstats as addition description of the preceding mount
> point. If the preceding mount point is NFS mountpoint, nfsiostat fails
> to parse this line eventually. This patch avoids parsing this line.
> 
> Signed-off-by: Manjunath Patil <manjunath.b.patil@oracle.com>
Committed... Sorry it took so long... 

steved.

> ---
>  tools/nfs-iostat/nfs-iostat.py |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/tools/nfs-iostat/nfs-iostat.py b/tools/nfs-iostat/nfs-iostat.py
> index 61d15a5..577a23d 100644
> --- a/tools/nfs-iostat/nfs-iostat.py
> +++ b/tools/nfs-iostat/nfs-iostat.py
> @@ -429,6 +429,8 @@ def parse_stats_file(filename):
>          words = line.split()
>          if len(words) == 0:
>              continue
> +	if line.startswith("no device mounted") :
> +            continue
>          if words[0] == 'device':
>              key = words[4]
>              new = [ line.strip() ]
> 
