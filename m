Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:27488 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753435Ab3K0PVf convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Nov 2013 10:21:35 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Subject: Re: [PATCH] proc: change permission of /proc/self/mountstats to 0644
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1385553135-23131-1-git-send-email-tigran.mkrtchyan@desy.de>
Date: Wed, 27 Nov 2013 10:21:29 -0500
Cc: linux-nfs@vger.kernel.org
Message-Id: <5069B68E-67AA-46C9-99C4-EE4839F71DFA@oracle.com>
References: <1385553135-23131-1-git-send-email-tigran.mkrtchyan@desy.de>
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 27, 2013, at 6:52 AM, Tigran Mkrtchyan <tigran.mkrtchyan@desy.de> wrote:

> While working on a ganglia plugin for NFS I run into problem that
> /proc/self/mountstats is readable by process owner only. As ganglia
> changes collector threads effective uid, it can't access to mountstats
> file any more.
> 
> The content of mountstats is equal for all processes and can be safely
> shared.

That is true only if there is a single mount namespace on your system.  The content of mountstats depends on each process's mount namespace.

However, I see that mounts and mountinfo, which also depend on a process's mount namespace, are all S_IRUGO.  I don't see a good reason mountstats should be different.

> 
> Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
> ---
> fs/proc/base.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/proc/base.c b/fs/proc/base.c
> index 03c8d74..d41e284 100644
> --- a/fs/proc/base.c
> +++ b/fs/proc/base.c
> @@ -2607,7 +2607,7 @@ static const struct pid_entry tgid_base_stuff[] = {
> 	LNK("exe",        proc_exe_link),
> 	REG("mounts",     S_IRUGO, proc_mounts_operations),
> 	REG("mountinfo",  S_IRUGO, proc_mountinfo_operations),
> -	REG("mountstats", S_IRUSR, proc_mountstats_operations),
> +	REG("mountstats", S_IRUGO, proc_mountstats_operations),
> #ifdef CONFIG_PROC_PAGE_MONITOR
> 	REG("clear_refs", S_IWUSR, proc_clear_refs_operations),
> 	REG("smaps",      S_IRUGO, proc_pid_smaps_operations),
> -- 
> 1.8.4.2
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




