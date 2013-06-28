Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:63300 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753131Ab3F1UGw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Jun 2013 16:06:52 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/5] NFS: Never use user credentials for lease renewal
Date: Fri, 28 Jun 2013 20:06:37 +0000
Message-ID: <1372449996.20188.2.camel@leira.trondhjem.org>
References: <20130625162233.36416.34947.stgit@seurat.1015granger.net>
	 <20130625162346.36416.25389.stgit@seurat.1015granger.net>
	 <1372449749.20188.0.camel@leira.trondhjem.org>
	 <A7FF4EEF-480D-492B-A248-3FF4098F3350@oracle.com>
In-Reply-To: <A7FF4EEF-480D-492B-A248-3FF4098F3350@oracle.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2013-06-28 at 16:03 -0400, Chuck Lever wrote:
> On Jun 28, 2013, at 4:02 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
> 
> > On Tue, 2013-06-25 at 12:23 -0400, Chuck Lever wrote:
> >> Don't try to use a non-UID-0 user credential for lease management,
> >> as that credential can change out from under us.  The server will
> >> block NFSv4 lease recovery with NFS4ERR_CLID_INUSE.
> >> 
> >> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> >> ---
> >> fs/nfs/nfs4proc.c |    4 ++--
> >> 1 file changed, 2 insertions(+), 2 deletions(-)
> >> 
> >> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> >> index d7ba561..5ba38b3 100644
> >> --- a/fs/nfs/nfs4proc.c
> >> +++ b/fs/nfs/nfs4proc.c
> >> @@ -6919,7 +6919,7 @@ static const struct nfs4_state_recovery_ops nfs40_reboot_recovery_ops = {
> >> 	.recover_open	= nfs4_open_reclaim,
> >> 	.recover_lock	= nfs4_lock_reclaim,
> >> 	.establish_clid = nfs4_init_clientid,
> >> -	.get_clid_cred	= nfs4_get_setclientid_cred,
> >> +	.get_clid_cred	= nfs4_get_exchange_id_cred,
> >> 	.detect_trunking = nfs40_discover_server_trunking,
> >> };
> >> 
> >> @@ -6942,7 +6942,7 @@ static const struct nfs4_state_recovery_ops nfs40_nograce_recovery_ops = {
> >> 	.recover_open	= nfs4_open_expired,
> >> 	.recover_lock	= nfs4_lock_expired,
> >> 	.establish_clid = nfs4_init_clientid,
> >> -	.get_clid_cred	= nfs4_get_setclientid_cred,
> >> +	.get_clid_cred	= nfs4_get_exchange_id_cred,
> >> };
> >> 
> >> #if defined(CONFIG_NFS_V4_1)
> >> 
> > 
> > Clearly not compile tested...
> 
> Yes, it was, with and without NFSV4 enabled.
> 
> Do you have a problem to report?

!defined(CONFIG_NFS_V4_1) would be the obvious place to start...


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
