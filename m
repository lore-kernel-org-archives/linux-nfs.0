Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21351 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753210Ab1I1Pte (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Sep 2011 11:49:34 -0400
Date: Wed, 28 Sep 2011 11:49:02 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/5] nfsd4: construct stateid from clientid and counter
Message-ID: <20110928154901.GG19435@pad.fieldses.org>
References: <20110919131415.GB32498@fieldses.org>
 <1316438143-1057-4-git-send-email-bfields@redhat.com>
 <4E81F55F.60306@netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E81F55F.60306@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Sep 27, 2011 at 12:10:07PM -0400, Bryan Schumaker wrote:
> On 09/19/2011 09:15 AM, J. Bruce Fields wrote:
> > Including the full clientid in the on-the-wire stateid allows more
> > reliable detection of bad vs. expired stateid's, simplifies code, and
> > ensures we won't reuse the opaque part of the stateid (as we currently
> > do when the same openowner closes and reopens the same file).
> > 
> > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > ---
> >  fs/nfsd/nfs4state.c |   58 +++++++++++---------------------------------------
> >  fs/nfsd/state.h     |   18 ++++-----------
> >  2 files changed, 18 insertions(+), 58 deletions(-)
> > 
> [ ... ]
> > diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> > index e807abb..d6aec4f 100644
> > --- a/fs/nfsd/state.h
> > +++ b/fs/nfsd/state.h
> > @@ -353,11 +349,9 @@ struct nfs4_replay {
> >  */
> >  
> >  struct nfs4_stateowner {
> 
> The comment describing this struct should probably be updated since so_idhash and a few other variables no longer exist.

Yeah, thanks for noticing.  The stateid comment doesn't seem that useful
either.  How about the following?

--b.

commit 44464d91b253c5340c8dd78927432bf1956b5789
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Wed Sep 28 11:47:20 2011 -0400

    nfsd4: cleanup state.h comments
    
    These comments are mostly out of date.
    
    Reported-by: Bryan Schumaker <bjschuma@netapp.com>

diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 22b065a..aa14f06 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -332,25 +332,6 @@ struct nfs4_replay {
 	char			rp_ibuf[NFSD4_REPLAY_ISIZE];
 };
 
-/*
-* nfs4_stateowner can either be an open_owner, or a lock_owner
-*
-*    so_idhash:  stateid_hashtbl[] for open owner, lockstateid_hashtbl[]
-*         for lock_owner
-*    so_strhash: ownerstr_hashtbl[] for open_owner, lock_ownerstr_hashtbl[]
-*         for lock_owner
-*    so_perclient: nfs4_client->cl_perclient entry - used when nfs4_client
-*         struct is reaped.
-*    so_perfilestate: heads the list of nfs4_ol_stateid (either open or lock) 
-*         and is used to ensure no dangling nfs4_ol_stateid references when we 
-*         release a stateowner.
-*    so_perlockowner: (open) nfs4_ol_stateid->st_perlockowner entry - used when
-*         close is called to reap associated byte-range locks
-*    so_close_lru: (open) stateowner is placed on this list instead of being
-*         reaped (when so_perfilestate is empty) to hold the last close replay.
-*         reaped by laundramat thread after lease period.
-*/
-
 struct nfs4_stateowner {
 	struct list_head        so_strhash;   /* hash by op_name */
 	struct list_head        so_stateids;
@@ -366,7 +347,14 @@ struct nfs4_stateowner {
 struct nfs4_openowner {
 	struct nfs4_stateowner	oo_owner; /* must be first field */
 	struct list_head        oo_perclient;
-	struct list_head	oo_close_lru; /* tail queue */
+	/*
+	 * We keep around openowners a little while after last close,
+	 * which saves clients from having to confirm, and allows us to
+	 * handle close replays if they come soon enough.  The close_lru
+	 * is a list of such openowners, to be reaped by the laundromat
+	 * thread eventually if they remain unused:
+	 */
+	struct list_head	oo_close_lru;
 	struct nfs4_ol_stateid *oo_last_closed_stid;
 	time_t			oo_time; /* time of placement on so_close_lru */
 #define NFS4_OO_CONFIRMED   1
@@ -443,23 +431,6 @@ static inline struct file *find_any_file(struct nfs4_file *f)
 		return f->fi_fds[O_RDONLY];
 }
 
-/*
-* nfs4_ol_stateid can either be an open stateid or (eventually) a lock stateid
-*
-* (open)nfs4_ol_stateid: one per (open)nfs4_stateowner, nfs4_file
-*
-* 	st_hash: stateid_hashtbl[] entry or lockstateid_hashtbl entry
-* 	st_perfile: file_hashtbl[] entry.
-* 	st_perfile_state: nfs4_stateowner->so_perfilestate
-*       st_perlockowner: (open stateid) list of lock nfs4_stateowners
-* 	st_access_bmap: used only for open stateid
-* 	st_deny_bmap: used only for open stateid
-*	st_openstp: open stateid lock stateid was derived from
-*
-* XXX: open stateids and lock stateids have diverged sufficiently that
-* we should consider defining separate structs for the two cases.
-*/
-
 /* "ol" stands for "Open or Lock".  Better suggestions welcome. */
 struct nfs4_ol_stateid {
 	struct nfs4_stid    st_stid;
