From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfsd41: renew_client must be called under the state
	lock
Date: Tue, 25 Aug 2009 17:59:48 -0400
Message-ID: <20090825215948.GG32708@fieldses.org>
References: <1250727716-28107-1-git-send-email-bhalevy@panasas.com> <20090824162904.GC4985@fieldses.org> <4A938D7A.3070908@panasas.com> <20090825131829.GA24049@fieldses.org> <4A941931.8070609@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:55327 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756005AbZHYV7r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Aug 2009 17:59:47 -0400
In-Reply-To: <4A941931.8070609@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 25, 2009 at 08:02:41PM +0300, Benny Halevy wrote:
> On Aug. 25, 2009, 16:18 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > On Tue, Aug 25, 2009 at 10:06:34AM +0300, Benny Halevy wrote:
> >> On Aug. 24, 2009, 19:29 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> >>> On Thu, Aug 20, 2009 at 03:21:56AM +0300, Benny Halevy wrote:
> >>>> nfsd4_sequence() should not renew the client state if the session was not
> >>>> found or if there was a bad slot.  This will also avoid dereferencing a
> >>>> null session pointer.
> >>>>
> >>>> FIXME: until we work out the state locking so we can use a
> >>>> spin lock to protect the cl_lru we need to take the state_lock
> >>>> to renew the client.
> >>> Is that first paragraph left over from some previous iteration of this
> >>> patch?
> >> Not really.
> >> It sort of sets up the stage for the state lock elimination project.
> >> That said, feel free to remove these lines as they are not particularly
> >> important for understanding what this patch does or how to do it better.
> > 
> > Note I was referring to "should not renew..."  That seems to describe a
> > problem that has already been fixed.
> 
> Hmm, apparently this came from "Do not renew state on error"
> which was squashed together with this patch.
> The text is still valid though somewhat unrelated to this patch's
> title.  Maybe a better title would be the original one:
> ""Do not renew state on error"

The title's right, it's just the comment that went stale.  I've applied
for 2.6.32 as follows.

--b.

commit fdf7875040506ca7e595dffef56cbd81ae6b384b
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Thu Aug 20 03:21:56 2009 +0300

    nfsd41: renew_client must be called under the state lock
    
    Until we work out the state locking so we can use a spin lock to protect
    the cl_lru, we need to take the state_lock to renew the client.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    [nfsd41: Do not renew state on error]
    Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d2a0524..8e5ac49 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1463,12 +1463,16 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 	spin_lock(&sessionid_lock);
 	status = nfserr_badsession;
 	session = find_in_sessionid_hashtbl(&seq->sessionid);
-	if (!session)
-		goto out;
+	if (!session) {
+		spin_unlock(&sessionid_lock);
+		goto err;
+	}
 
 	status = nfserr_badslot;
-	if (seq->slotid >= session->se_fchannel.maxreqs)
-		goto out;
+	if (seq->slotid >= session->se_fchannel.maxreqs) {
+		spin_unlock(&sessionid_lock);
+		goto err;
+	}
 
 	slot = &session->se_slots[seq->slotid];
 	dprintk("%s: slotid %d\n", __func__, seq->slotid);
@@ -1481,10 +1485,12 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 		 * for nfsd4_svc_encode_compoundres processing */
 		status = nfsd4_replay_cache_entry(resp, seq);
 		cstate->status = nfserr_replay_cache;
-		goto replay_cache;
-	}
-	if (status)
 		goto out;
+	}
+	if (status) {
+		spin_unlock(&sessionid_lock);
+		goto err;
+	}
 
 	/* Success! bump slot seqid */
 	slot->sl_inuse = true;
@@ -1497,15 +1503,17 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 	cstate->slot = slot;
 	cstate->session = session;
 
-replay_cache:
-	/* Renew the clientid on success and on replay.
-	 * Hold a session reference until done processing the compound:
+	/* Hold a session reference until done processing the compound:
 	 * nfsd4_put_session called only if the cstate slot is set.
 	 */
-	renew_client(session->se_client);
 	nfsd4_get_session(session);
 out:
 	spin_unlock(&sessionid_lock);
+	/* Renew the clientid on success and on replay */
+	nfs4_lock_state();
+	renew_client(session->se_client);
+	nfs4_unlock_state();
+err:
 	dprintk("%s: return %d\n", __func__, ntohl(status));
 	return status;
 }
