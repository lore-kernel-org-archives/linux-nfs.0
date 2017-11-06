Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:46608 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751530AbdKFWYD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 6 Nov 2017 17:24:03 -0500
Date: Mon, 6 Nov 2017 17:24:02 -0500
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: Andrew W Elble <aweits@rit.edu>
Cc: Trond Myklebust <trondmy@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3] nfsd: deal with revoked delegations appropriately
Message-ID: <20171106222402.GD599@fieldses.org>
References: <20171103180631.76071-1-aweits@rit.edu>
 <1509734212.21477.16.camel@primarydata.com>
 <20171106151531.GB599@fieldses.org>
 <m2fu9rqpqo.fsf@discipline.rit.edu>
 <20171106193528.GA13456@fieldses.org>
 <m24lq7qev4.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <m24lq7qev4.fsf@discipline.rit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 06, 2017 at 04:25:19PM -0500, Andrew W Elble wrote:
> 
> "bfields@fieldses.org" <bfields@fieldses.org> writes:
> 
> > I'm just looking for a concise explanation of why your patch is
> > important.  And I probably haven't dug enough, but I'm still not quite
> > following.
> >
> > If I understand right, the only visible change from your patch will be
> > returning DELEG_REVOKED instead of BAD_STATEID to 4.1 clients in some
> > cases.  I'm not clear what the result was (for old or new clients)--a
> > client left believing it held a delegation when it didn't, or a client
> > entering an infinite state manager loop?
> 
> The current Linux client will "lose" a delegation on DELEGRETURN if it
> does not see NFS4ERR_DELEG_REVOKED. This is unrecoverable and will
> result in the client state manager looping unable to satisfy the
> server's inevitable assertion of SEQ4_STATUS_RECALLABLE_STATE_REVOKED.
> 
> RFC5661 10.2.1: "A client normally finds out about revocation of a delegation
> when it uses a stateid associated with a delegation and receives one of
> the errors NFS4ERR_EXPIRED, NFS4ERR_ADMIN_REVOKED, or NFS4ERR_DELEG_REVOKED."

Got it, thanks for your persistence!  Committing as follows.

--b.

commit 4e9fd30e4432
Author: Andrew Elble <aweits@rit.edu>
Date:   Fri Nov 3 14:06:31 2017 -0400

    nfsd: deal with revoked delegations appropriately
    
    If a delegation has been revoked by the server, operations using that
    delegation should error out with NFS4ERR_DELEG_REVOKED in the >4.1
    case, and NFS4ERR_BAD_STATEID otherwise.
    
    The server needs NFSv4.1 clients to explicitly free revoked delegations.
    If the server returns NFS4ERR_DELEG_REVOKED, the client will do that;
    otherwise it may just forget about the delegation and be unable to
    recover when it later sees SEQ4_STATUS_RECALLABLE_STATE_REVOKED set on a
    SEQUENCE reply.  That can cause the Linux 4.1 client to loop in its
    stage manager.
    
    Signed-off-by: Andrew Elble <aweits@rit.edu>
    Reviewed-by: Trond Myklebust <trond.myklebust@primarydata.com>
    Cc: stable@vger.kernel.org
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index ecbc7b0dfa4d..b82817767b9d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4016,7 +4016,8 @@ static struct nfs4_delegation *find_deleg_stateid(struct nfs4_client *cl, statei
 {
 	struct nfs4_stid *ret;
 
-	ret = find_stateid_by_type(cl, s, NFS4_DELEG_STID);
+	ret = find_stateid_by_type(cl, s,
+				NFS4_DELEG_STID|NFS4_REVOKED_DELEG_STID);
 	if (!ret)
 		return NULL;
 	return delegstateid(ret);
@@ -4039,6 +4040,12 @@ nfs4_check_deleg(struct nfs4_client *cl, struct nfsd4_open *open,
 	deleg = find_deleg_stateid(cl, &open->op_delegate_stateid);
 	if (deleg == NULL)
 		goto out;
+	if (deleg->dl_stid.sc_type == NFS4_REVOKED_DELEG_STID) {
+		nfs4_put_stid(&deleg->dl_stid);
+		if (cl->cl_minorversion)
+			status = nfserr_deleg_revoked;
+		goto out;
+	}
 	flags = share_access_to_flags(open->op_share_access);
 	status = nfs4_check_delegmode(deleg, flags);
 	if (status) {
@@ -4908,6 +4915,16 @@ nfsd4_lookup_stateid(struct nfsd4_compound_state *cstate,
 		     struct nfs4_stid **s, struct nfsd_net *nn)
 {
 	__be32 status;
+	bool return_revoked = false;
+
+	/*
+	 *  only return revoked delegations if explicitly asked.
+	 *  otherwise we report revoked or bad_stateid status.
+	 */
+	if (typemask & NFS4_REVOKED_DELEG_STID)
+		return_revoked = true;
+	else if (typemask & NFS4_DELEG_STID)
+		typemask |= NFS4_REVOKED_DELEG_STID;
 
 	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid))
 		return nfserr_bad_stateid;
@@ -4922,6 +4939,12 @@ nfsd4_lookup_stateid(struct nfsd4_compound_state *cstate,
 	*s = find_stateid_by_type(cstate->clp, stateid, typemask);
 	if (!*s)
 		return nfserr_bad_stateid;
+	if (((*s)->sc_type == NFS4_REVOKED_DELEG_STID) && !return_revoked) {
+		nfs4_put_stid(*s);
+		if (cstate->minorversion)
+			return nfserr_deleg_revoked;
+		return nfserr_bad_stateid;
+	}
 	return nfs_ok;
 }
 
