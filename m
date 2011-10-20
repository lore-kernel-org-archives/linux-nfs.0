Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vw0-f46.google.com ([209.85.212.46]:58931 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751659Ab1JTTQK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Oct 2011 15:16:10 -0400
Received: by vws1 with SMTP id 1so2375387vws.19
        for <linux-nfs@vger.kernel.org>; Thu, 20 Oct 2011 12:16:09 -0700 (PDT)
Message-ID: <4EA07375.30303@tonian.com>
Date: Thu, 20 Oct 2011 15:16:05 -0400
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 5/7] nfsd4: implement NFS4_SHARE_WANT_NO_DELEG, NFS4_OPEN_DELEGATE_NONE_EXT
References: <4E9F82FC.2000904@tonian.com> <1319076801-13474-1-git-send-email-benny@tonian.com> <20111020115224.GH5444@fieldses.org> <1456421465-1319114189-cardhu_decombobulator_blackberry.rim.net-173541571-@b18.c3.bise3.blackberry> <20111020124713.GP5444@fieldses.org>
In-Reply-To: <20111020124713.GP5444@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2011-10-20 08:47, J. Bruce Fields wrote:
> On Thu, Oct 20, 2011 at 12:36:25PM +0000, Benny Halevy wrote:
>> OK, I read you.  Just please take note that WANT_NO_DELEG flag is important to simplified clients that do not support delegations, like the one I was testing against in the BAT, and it is the only one in use that I could tell.
> 
> If you can suggest an implementation that meets the minimum required by
> the spec, I'd happily take it....
> 
> It might not be much harder: it's probably just a matter of returrning
> the right OPEN_DELEGATE_NONE_EXT?
> 
> Though unfortunately there's not a "why" for "I just didn't feel like
> giving you one", so we probably would have to make an effort to detect
> the different case.

Agreed.  It could have been a good to have such a reason.

> 
> Also, I wonder if it's wise for a client to depend on this--it really is
> an optional feature as far as I can tell.  It would be safer to teach
> the client just to handle delegations in the simplest way possible
> (possibly just return them immediately?).
> 

That's true.

How about the following? (untested squashme over this patch)

>From ab9e79564fee05a0f3f369fc134bbace1543ac4d Mon Sep 17 00:00:00 2001
From: Benny Halevy <bhalevy@tonian.com>
Date: Thu, 20 Oct 2011 08:00:03 -0700
Subject: [PATCH] SQUASHME: nfsd4: implement why_no_deleg

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/nfs4state.c |   50 +++++++++++++++++++++++++++++++++++++++++++++-----
 fs/nfsd/nfs4xdr.c   |    7 ++++++-
 fs/nfsd/xdr4.h      |    1 +
 3 files changed, 52 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d00c246..2cdd2b3 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2914,7 +2914,7 @@ static int nfs4_set_delegation(struct nfs4_delegation *dp, int flag)
 	struct nfs4_delegation *dp;
 	struct nfs4_openowner *oo = container_of(stp->st_stateowner, struct nfs4_openowner, oo_owner);
 	int cb_up;
-	int status, flag = 0;
+	int status = 0, flag = 0;

 	cb_up = nfsd4_cb_channel_good(oo->oo_owner.so_client);
 	flag = NFS4_OPEN_DELEGATE_NONE;
@@ -2955,11 +2955,32 @@ static int nfs4_set_delegation(struct nfs4_delegation *dp, int flag)
 	dprintk("NFSD: delegation stateid=" STATEID_FMT "\n",
 		STATEID_VAL(&dp->dl_stid.sc_stateid));
 out:
-	if (open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS
-			&& flag == NFS4_OPEN_DELEGATE_NONE
-			&& open->op_delegate_type != NFS4_OPEN_DELEGATE_NONE)
-		dprintk("NFSD: WARNING: refusing delegation reclaim\n");
 	open->op_delegate_type = flag;
+	if (flag == NFS4_OPEN_DELEGATE_NONE) {
+		if (open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS &&
+		    open->op_delegate_type != NFS4_OPEN_DELEGATE_NONE)
+			dprintk("NFSD: WARNING: refusing delegation reclaim\n");
+
+		if (open->op_deleg_want) {
+			open->op_delegate_type = NFS4_OPEN_DELEGATE_NONE_EXT;
+			if (status == -EAGAIN)
+				open->op_why_no_deleg = WND4_CONTENTION;
+			else {
+				open->op_why_no_deleg = WND4_RESOURCE;
+				switch (open->op_deleg_want) {
+				case NFS4_SHARE_WANT_READ_DELEG:
+				case NFS4_SHARE_WANT_WRITE_DELEG:
+				case NFS4_SHARE_WANT_ANY_DELEG:
+					break;
+				case NFS4_SHARE_WANT_CANCEL:
+					open->op_why_no_deleg = WND4_CANCELLED;
+					break;
+				case NFS4_SHARE_WANT_NO_DELEG:
+					BUG();	/* not supposed to get here */
+				}
+			}
+		}
+	}
 	return;
 out_free:
 	nfs4_put_delegation(dp);
@@ -3036,6 +3057,7 @@ static int nfs4_set_delegation(struct nfs4_delegation *dp, int flag)

 		if (open->op_deleg_want & NFS4_SHARE_WANT_NO_DELEG) {
 			open->op_delegate_type = NFS4_OPEN_DELEGATE_NONE_EXT;
+			open->op_why_no_deleg = WND4_NOT_WANTED;
 			goto nodeleg;
 		}
 	}
@@ -3051,6 +3073,24 @@ static int nfs4_set_delegation(struct nfs4_delegation *dp, int flag)
 	dprintk("%s: stateid=" STATEID_FMT "\n", __func__,
 		STATEID_VAL(&stp->st_stid.sc_stateid));
 out:
+	/* 4.1 client trying to upgrade/downgrade delegation? */
+	if (open->op_delegate_type == NFS4_OPEN_DELEGATE_NONE && dp &&
+	    open->op_deleg_want) {
+		if (open->op_deleg_want == NFS4_SHARE_WANT_READ_DELEG &&
+		    dp->dl_type == NFS4_OPEN_DELEGATE_WRITE) {
+			open->op_delegate_type = NFS4_OPEN_DELEGATE_NONE_EXT;
+			open->op_why_no_deleg = WND4_NOT_SUPP_DOWNGRADE;
+		} else if (open->op_deleg_want == NFS4_SHARE_WANT_WRITE_DELEG &&
+			   dp->dl_type == NFS4_OPEN_DELEGATE_WRITE) {
+			open->op_delegate_type = NFS4_OPEN_DELEGATE_NONE_EXT;
+			open->op_why_no_deleg = WND4_NOT_SUPP_DOWNGRADE;
+		}
+		/* Otherwise the client must be confused wanting a delegation
+		 * it already has, therefore we don't return
+		 * NFS4_OPEN_DELEGATE_NONE_EXT and reason.
+		 */
+	}
+
 	if (fp)
 		put_nfs4_file(fp);
 	if (status == 0 && open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS)
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 9b838e9..f2c1338 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3035,7 +3035,12 @@ static __be32 nfsd4_encode_bind_conn_to_session(struct nfsd4_compoundres *resp,
 		ADJUST_ARGS();
 		break;
 	case NFS4_OPEN_DELEGATE_NONE_EXT: /* 4.1 */
-		WRITE32(WND4_NOT_WANTED);	/* only reason for now */
+		WRITE32(open->op_why_no_deleg);
+		switch (open->op_why_no_deleg) {
+		case WND4_CONTENTION:
+		case WND4_RESOURCE:
+			WRITE32(0);	/* deleg signaling not supported yet */
+		}
 		break;
 	default:
 		BUG();
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 1e5ca95..d20d87e 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -214,6 +214,7 @@ struct nfsd4_open {
 	struct xdr_netobj op_fname;	    /* request - everything but CLAIM_PREV */
 	u32		op_delegate_type;   /* request - CLAIM_PREV only */
 	stateid_t       op_delegate_stateid; /* request - response */
+	u32		op_why_no_deleg;    /* response - DELEG_NONE_EXT only */
 	u32		op_create;     	    /* request */
 	u32		op_createmode;      /* request */
 	u32		op_bmval[3];        /* request */
-- 
1.7.6

