Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-3.desy.de ([131.169.56.156]:51665 "EHLO smtp-o-3.desy.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751688AbeCPJbz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 16 Mar 2018 05:31:55 -0400
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
        by smtp-o-3.desy.de (DESY-O-3) with ESMTP id 100F8280662
        for <linux-nfs@vger.kernel.org>; Fri, 16 Mar 2018 10:31:54 +0100 (CET)
Date: Fri, 16 Mar 2018 10:31:52 +0100 (CET)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: NeilBrown <neilb@suse.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Message-ID: <584484878.12780264.1521192712528.JavaMail.zimbra@desy.de>
In-Reply-To: <878tasc3ag.fsf@notabene.neil.brown.name>
References: <87bmfoc3yi.fsf@notabene.neil.brown.name> <878tasc3ag.fsf@notabene.neil.brown.name>
Subject: Re: [PATCH - v2] NFSv4: handle EINVAL from EXCHANGE_ID better.
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi Neil,

according to rfc5661, NFS4ERR_INVAL is returned by the server if it
thinks that client sends an invalid request (e.g. points to a client bug)
or server misinterpret it (broken server).

With your change instead of failing the mount, client will silently go for
v4.0, even v4.1 mount was requested and produce undesirable behavior, e.g.
proxy-io instead of pnfs. I fill prefer fail-fast instead of long debug
sessions.

On the other hand, I understand, that it's not always possible to fix server
or clients in production environment and time-to-time workarounds are necessary.


Tigran.


----- Original Message -----
> From: "NeilBrown" <neilb@suse.com>
> To: "Trond Myklebust" <trond.myklebust@primarydata.com>, "Anna Schumaker" <anna.schumaker@netapp.com>
> Cc: "linux-nfs" <linux-nfs@vger.kernel.org>
> Sent: Friday, March 16, 2018 12:44:23 AM
> Subject: [PATCH - v2] NFSv4: handle EINVAL from EXCHANGE_ID better.

> nfs4_proc_exchange_id() can return -EINVAL if the server
> reported NFS4INVAL (which I have seen in a packet trace),
> or nfs4_check_cl_exchange_flags() exchange flags detects
> a problem.
> Each of these mean that NFSv4.1 later cannot be use, but
> they should not prevent fallback to NFSv4.0.
> 
> Currently this EINVAL error is returned by nfs4_proc_exchange_id() to
> nfs41_discover_server_trunking(), and thence to
> nfs4_discover_server_trunking().
> nfs4_discover_server_trunking() doesn't understand EINVAL, so converts
> it to EIO which causes mount.nfs to think something is horribly wrong
> and to give up.
> 
> It would be a more graceful failure if nfs4_discover_server_trunking()
> mapped -EINVAL to -EPROTONOSUPPORT - a failure to negotiate a client
> ID clearly shows that NFSv4.1 cannot be supported, but isn't as
> general a failure as EIO.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
> 
> Sorry - a bit too trigger-happy with that first version of the patch.
> 
> NeilBrown
> 
> fs/nfs/nfs4state.c | 2 ++
> 1 file changed, 2 insertions(+)
> 
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index 91a4d4eeb235..b988e460553d 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -2219,6 +2219,8 @@ int nfs4_discover_server_trunking(struct nfs_client *clp,
> 		clnt = clp->cl_rpcclient;
> 		goto again;
> 
> +	case -NFS4ERR_INVAL:
> +		/* Server confused - assume this minor isn't supported */
> 	case -NFS4ERR_MINOR_VERS_MISMATCH:
> 		status = -EPROTONOSUPPORT;
> 		break;
> --
> 2.14.0.rc0.dirty
