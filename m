Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45652 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751906AbeFYPhJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 25 Jun 2018 11:37:09 -0400
Subject: Re: [PATCH] nfsstat: fix typo causing --mounts unrecognized option
To: yongcheng.yang@gmail.com, linux-nfs@vger.kernel.org
References: <1529644004-15544-1-git-send-email-yongcheng.yang@gmail.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <a8810502-85fa-d55a-879e-20f99a984b7e@RedHat.com>
Date: Mon, 25 Jun 2018 11:37:08 -0400
MIME-Version: 1.0
In-Reply-To: <1529644004-15544-1-git-send-email-yongcheng.yang@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/22/2018 01:06 AM, yongcheng.yang@gmail.com wrote:
> From: Yongcheng Yang <yongcheng.yang@gmail.com>
> 
> This reverts commit acf95d32a44fd8357c24e8a04ec53fc6900bfc58
> 
> Signed-off-by: Yongcheng Yang <yongcheng.yang@gmail.com>
Committed... 

steved.

> ---
> 
> Hi Steve,
> 
> To keep pace with the (nfsstat) man page, "mounted" should be replaced by "mounts".
> 
> Test logs:
> 
> [root@ nfsstat]# rpm -q nfs-utils
> nfs-utils-2.3.1-xxx
> [root@ nfsstat]# nfsstat --mounts
> nfsstat: unrecognized option '--mounts'
> Try `nfsstat --help' for more information.
> 
> [root@ nfsstat]# nfsstat.new --mounts
> /mnt from localhost:/export_test
>  Flags: rw,relatime,vers=4.2,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp6,timeo=600,retrans=2,sec=sys,clientaddr=::1,local_lock=none,addr=::1
> 
> [root@ nfsstat]# 
> 
> Thanks,
> Yongcheng
> 
> ---
> 
>  utils/nfsstat/nfsstat.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
> index 8fccea7..ca84532 100644
> --- a/utils/nfsstat/nfsstat.c
> +++ b/utils/nfsstat/nfsstat.c
> @@ -340,7 +340,7 @@ static struct option longopts[] =
>  	{ "all", 0, 0, 'v' },
>  	{ "auto", 0, 0, '\3' },
>  	{ "client", 0, 0, 'c' },
> -	{ "mounted", 0, 0, 'm' },
> +	{ "mounts", 0, 0, 'm' },
>  	{ "nfs", 0, 0, 'n' },
>  	{ "rpc", 0, 0, 'r' },
>  	{ "server", 0, 0, 's' },
> 
