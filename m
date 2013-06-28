Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f44.google.com ([209.85.212.44]:63945 "EHLO
	mail-vb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750961Ab3F1Lvo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Jun 2013 07:51:44 -0400
MIME-Version: 1.0
In-Reply-To: <20130626061448.32202.192.stgit@localhost.localdomain>
References: <20130624075245.17104.6279.stgit@localhost.localdomain> <20130626061448.32202.192.stgit@localhost.localdomain>
From: William Dauchy <wdauchy@gmail.com>
Date: Fri, 28 Jun 2013 13:51:23 +0200
Message-ID: <CAJ75kXaRTfkCvT+=PdmHaRAXGKuMYW7aRRpGQJrQkfi6nDO9DQ@mail.gmail.com>
Subject: Re: [PATCH v4] SUNRPC: fix races on PipeFS UMOUNT notifications
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>, devel@openvz.org,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        jlayton@redhat.com
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 26, 2013 at 8:15 AM, Stanislav Kinsbursky
<skinsbursky@parallels.com> wrote:
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index b827a4b..41f180c 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -236,8 +236,6 @@ static struct rpc_clnt *rpc_get_client_for_event(struct net *net, int event)
>                         continue;
>                 if (rpc_clnt_skip_event(clnt, event))
>                         continue;
> -               if (atomic_inc_not_zero(&clnt->cl_count) == 0)
> -                       continue;
>                 spin_unlock(&sn->rpc_client_lock);
>                 return clnt;
>         }
> @@ -254,7 +252,6 @@ static int rpc_pipefs_event(struct notifier_block *nb, unsigned long event,
>
>         while ((clnt = rpc_get_client_for_event(sb->s_fs_info, event))) {
>                 error = __rpc_pipefs_event(clnt, event, sb);
> -               rpc_release_client(clnt);
>                 if (error)
>                         break;
>         }
> @@ -641,8 +638,8 @@ rpc_free_client(struct rpc_clnt *clnt)
>                         rcu_dereference(clnt->cl_xprt)->servername);
>         if (clnt->cl_parent != clnt)
>                 rpc_release_client(clnt->cl_parent);
> -       rpc_unregister_client(clnt);
>         rpc_clnt_remove_pipedir(clnt);
> +       rpc_unregister_client(clnt);
>         rpc_free_iostats(clnt->cl_metrics);
>         kfree(clnt->cl_principal);
>         clnt->cl_metrics = NULL;
> diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
> index c512448..9b4ec5b 100644
> --- a/net/sunrpc/rpc_pipe.c
> +++ b/net/sunrpc/rpc_pipe.c
> @@ -1165,12 +1165,12 @@ static void rpc_kill_sb(struct super_block *sb)
>                 goto out;
>         }
>         sn->pipefs_sb = NULL;
> -       mutex_unlock(&sn->pipefs_sb_lock);
>         dprintk("RPC:       sending pipefs UMOUNT notification for net %p%s\n",
>                 net, NET_NAME(net));
>         blocking_notifier_call_chain(&rpc_pipefs_notifier_list,
>                                            RPC_PIPEFS_UMOUNT,
>                                            sb);
> +       mutex_unlock(&sn->pipefs_sb_lock);
>         put_net(net);
>  out:
>         kill_litter_super(sb);

are these patches validated?
any chance to see them in tree soon? I wasn't able to find them on
http://git.linux-nfs.org/?p=trondmy/linux-nfs.git

Thanks,
--
William
