Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:41240 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752911AbeEONGt (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 15 May 2018 09:06:49 -0400
Received: by mail-qt0-f196.google.com with SMTP id g13-v6so67945qth.8
        for <linux-nfs@vger.kernel.org>; Tue, 15 May 2018 06:06:48 -0700 (PDT)
Received: from unused (nat-pool-rdu-t.redhat.com. [66.187.233.202])
        by smtp.gmail.com with ESMTPSA id b133-v6sm4188qkc.41.2018.05.15.06.06.47
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 May 2018 06:06:47 -0700 (PDT)
Message-ID: <1526389606.3803.4.camel@redhat.com>
Subject: Re: [PATCH] Fix possible stack smash in
 nfs_idmap_read_and_verify_message
From: David Wysochanski <dwysocha@redhat.com>
To: linux-nfs@vger.kernel.org
Date: Tue, 15 May 2018 09:06:46 -0400
In-Reply-To: <20180417201118.17841-1-dwysocha@redhat.com>
References: <20180417201118.17841-1-dwysocha@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2018-04-17 at 16:11 -0400, Dave Wysochanski wrote:
> In nfs_idmap_read_and_verify_message there is an unprotected sprintf
> that converts the __u32 'im_id' from struct idmap_msg to 'id_str'
> that is a stack variable of 'NFS_UINT_MAXLEN' (defined as 11).
> If a uid or gid value is > 2147483647 = 0x7fffffff we corrupt
> kernel memory by one byte and if CONFIG_CC_STACKPROTECTOR_STRONG
> is set we see a stack-protector panic as follows:
> 
> [11558053.616565] Kernel panic - not syncing: stack-protector: Kernel stack is corrupted in: ffffffffa05b8a8c
> 
> [11558053.639063] CPU: 6 PID: 9423 Comm: rpc.idmapd Tainted: G        W      ------------ T 3.10.0-514.el7.x86_64 #1
> [11558053.641990] Hardware name: Red Hat OpenStack Compute, BIOS 1.10.2-3.el7_4.1 04/01/2014
> [11558053.644462]  ffffffff818c7bc0 00000000b1f3aec1 ffff880de0f9bd48 ffffffff81685eac
> [11558053.646430]  ffff880de0f9bdc8 ffffffff8167f2b3 ffffffff00000010 ffff880de0f9bdd8
> [11558053.648313]  ffff880de0f9bd78 00000000b1f3aec1 ffffffff811dcb03 ffffffffa05b8a8c
> [11558053.650107] Call Trace:
> [11558053.651347]  [<ffffffff81685eac>] dump_stack+0x19/0x1b
> [11558053.653013]  [<ffffffff8167f2b3>] panic+0xe3/0x1f2
> [11558053.666240]  [<ffffffff811dcb03>] ? kfree+0x103/0x140
> [11558053.682589]  [<ffffffffa05b8a8c>] ? idmap_pipe_downcall+0x1cc/0x1e0 [nfsv4]
> [11558053.689710]  [<ffffffff810855db>] __stack_chk_fail+0x1b/0x30
> [11558053.691619]  [<ffffffffa05b8a8c>] idmap_pipe_downcall+0x1cc/0x1e0 [nfsv4]
> [11558053.693867]  [<ffffffffa00209d6>] rpc_pipe_write+0x56/0x70 [sunrpc]
> [11558053.695763]  [<ffffffff811fe12d>] vfs_write+0xbd/0x1e0
> [11558053.702236]  [<ffffffff810acccc>] ? task_work_run+0xac/0xe0
> [11558053.704215]  [<ffffffff811fec4f>] SyS_write+0x7f/0xe0
> [11558053.709674]  [<ffffffff816964c9>] system_call_fastpath+0x16/0x1b
> 
> Fix this by snprintf and a safe length based on sizeof(id_str).
> 
> Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
> Reported-by: Stephen Johnston <sjohnsto@redhat.com>
> ---
>  fs/nfs/nfs4idmap.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/nfs4idmap.c b/fs/nfs/nfs4idmap.c
> index 22dc30a679a0..a8c663f8dd99 100644
> --- a/fs/nfs/nfs4idmap.c
> +++ b/fs/nfs/nfs4idmap.c
> @@ -627,7 +627,7 @@ static int nfs_idmap_read_and_verify_message(struct idmap_msg *im,
>  		if (strcmp(upcall->im_name, im->im_name) != 0)
>  			break;
>  		/* Note: here we store the NUL terminator too */
> -		len = sprintf(id_str, "%d", im->im_id) + 1;
> +		len = snprintf(id_str, sizeof(id_str), "%u", im->im_id) + 1;
>  		ret = nfs_idmap_instantiate(key, authkey, id_str, len);
>  		break;
>  	case IDMAP_CONV_IDTONAME:


I did not see any reply to this and we did have one customer hit this
which caused a considerable outage of many machines.  In essence once
this happened, it became a DoS on all machines using idmapping and they
implemented a temporary workaround.

Anna / Trond - if you need me to improve the patch header or want
clarification or see a problem with it, please let me know.

Thanks.
