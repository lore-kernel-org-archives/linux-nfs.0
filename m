Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:11638 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754156AbbAEULQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Jan 2015 15:11:16 -0500
Message-ID: <54AAEFE2.4030607@Netapp.com>
Date: Mon, 5 Jan 2015 15:11:14 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Tom Haynes <thomas.haynes@primarydata.com>,
        Trond Myklebust <Trond.Myklebust@primarydata.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 14/49] nfs4: export nfs4_sequence_done
References: <1419405208-25975-1-git-send-email-loghyr@primarydata.com> <1419405208-25975-15-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1419405208-25975-15-git-send-email-loghyr@primarydata.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Peng and Tom,

On 12/24/2014 02:12 AM, Tom Haynes wrote:
> From: Peng Tao <tao.peng@primarydata.com>
> 
> Signed-off-by: Peng Tao <tao.peng@primarydata.com>
> Signed-off-by: Tom Haynes <Thomas.Haynes@primarydata.com>
> ---
>  fs/nfs/nfs4_fs.h  | 2 ++
>  fs/nfs/nfs4proc.c | 4 ++--
>  2 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
> index 90c4ffe..b3c771e 100644
> --- a/fs/nfs/nfs4_fs.h
> +++ b/fs/nfs/nfs4_fs.h
> @@ -447,6 +447,8 @@ extern int nfs40_setup_sequence(struct nfs4_slot_table *tbl,
>  				struct nfs4_sequence_args *args,
>  				struct nfs4_sequence_res *res,
>  				struct rpc_task *task);
> +extern int nfs4_sequence_done(struct rpc_task *task,
> +			      struct nfs4_sequence_res *res);
>  
>  extern void nfs4_free_lock_state(struct nfs_server *server, struct nfs4_lock_state *lsp);
>  
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 9b1a481..4883a42 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -694,8 +694,7 @@ out_retry:
>  }
>  EXPORT_SYMBOL_GPL(nfs41_sequence_done);
>  
> -static int nfs4_sequence_done(struct rpc_task *task,
> -			       struct nfs4_sequence_res *res)
> +int nfs4_sequence_done(struct rpc_task *task, struct nfs4_sequence_res *res)
>  {
>  	if (res->sr_slot == NULL)
>  		return 1;

When I compile with:
	CONFIG_NFS_V4_2=n
	CONFIG_NFS_V4_1=n
	CONFIG_NFS_V4=y
	CONFIG_NFS_V3=y
	CONFIG_NFS_V2=y

I get: 
fs/nfs/nfs4proc.c:826:12: error: static declaration of 'nfs4_sequence_done' follows non-static declaration
 static int nfs4_sequence_done(struct rpc_task *task,
            ^
In file included from fs/nfs/nfs4proc.c:59:0:
fs/nfs/nfs4_fs.h:450:12: note: previous declaration of 'nfs4_sequence_done' was here
 extern int nfs4_sequence_done(struct rpc_task *task,
            ^
scripts/Makefile.build:257: recipe for target 'fs/nfs/nfs4proc.o' failed
make[2]: *** [fs/nfs/nfs4proc.o] Error 1
scripts/Makefile.build:402: recipe for target 'fs/nfs' failed
make[1]: *** [fs/nfs] Error 2
Makefile:938: recipe for target 'fs' failed
make: *** [fs] Error 2

Thanks,
Anna

> @@ -703,6 +702,7 @@ static int nfs4_sequence_done(struct rpc_task *task,
>  		return nfs40_sequence_done(task, res);
>  	return nfs41_sequence_done(task, res);
>  }
> +EXPORT_SYMBOL_GPL(nfs4_sequence_done);
>  
>  int nfs41_setup_sequence(struct nfs4_session *session,
>  				struct nfs4_sequence_args *args,
> 

