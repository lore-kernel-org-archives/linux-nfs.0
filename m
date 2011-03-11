Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:38214 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751374Ab1CKEIB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Mar 2011 23:08:01 -0500
Date: Fri, 11 Mar 2011 15:07:49 +1100
From: NeilBrown <neilb@suse.de>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Nick Piggin <npiggin@gmail.com>,
        Nick Piggin <npiggin@kernel.dk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH] fs/dcache: allow __d_obtain_alias() to return unhashed
 dentries
Message-ID: <20110311150749.2fa2be66@notabene.brown>
In-Reply-To: <20110310105821.GE22723@ZenIV.linux.org.uk>
References: <20101214220102.GM24828@fieldses.org>
	<20101217180022.GB11515@fieldses.org>
	<20101218020118.GA3179@amd>
	<20101218161609.GA22150@fieldses.org>
	<AANLkTingRv_gtRSctGzMfYrKg02M_sKj97HSQPRm_mA_@mail.gmail.com>
	<20101227234641.GA22248@fieldses.org>
	<20110118204509.GA10903@fieldses.org>
	<AANLkTikL2CDSWQJ1QH_Y4G-j70Vd=VesNMMnYTmMGHC9@mail.gmail.com>
	<20110118220817.GF10903@fieldses.org>
	<20110308181320.GA15566@fieldses.org>
	<20110310105821.GE22723@ZenIV.linux.org.uk>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 10 Mar 2011 10:58:21 +0000 Al Viro <viro@ZenIV.linux.org.uk> wrote:

> On Tue, Mar 08, 2011 at 01:13:20PM -0500, J. Bruce Fields wrote:
> 
> > Al, do you have this in your queue to look at?  Need me to resend?  Or
> > should it take some other route?
> 
> It's in queue, but I'd be a lot happier if I understood what's going on
> with __d_find_alias() elsewhere.  Namely, in d_splice_alias().  The thing
> is, unless I'm missing something we ought to use __d_find_any_alias()
> there as well.  Directories really, _really_ should not have more than
> one alias.  And what we get is really weird:
> 	* find (the only) alias
> 	* if it doesn't exist, create one (OK, no problem)
> 	* if it does exist and happens to be IS_ROOT and DCACHE_DISCONNECTED,
> move it (also fine, modulo rather useless BUG_ON() in there)
> 	* if it does exist and either isn't IS_ROOT or not DCACHE_DISCONNECTED,
> add a new alias and say nothing.
> 
> The last part looks very strange.  I'd been staring at the history of this
> function and I _think_ it's a rudiment of period when we used that stuff for
> non-directories as well.  It used to be directory-only; then Neil had
> switched it to non-directories as well (in "Fix disconnected dentries on NFS
> exports" back in 2004), adding want_discon argument to __d_find_alias() in
> process and using it instead of open-coded equivalent of __d_find_any_alias().
> Then, two years later, in "knfsd: close a race-opportunity in d_splice_alias"
> he'd made that code directory-only again, at which point we arrived to the
> current situation.
> 
> Neil, is there some reason I'm missing that makes __d_find_alias() right in
> there?  And do we still need the second argument in __d_find_alias()?
> 
> Anyway, Bruce's patch goes in tonight's push, but I'd love to see that
> mess cleaned up as well or at least explained.


ahh.... that takes me back ... :-)

Thanks for identifying those patches Al - it saved me a lot of time.

What can I say.... the first patch is clearly wrong, for the reasons
mentioned in the second patch.  And the second patch is wrong, partly
because of the reasons you give and partly because it re-introduces the
the bug that the first patch aimed to fix.  All very sad really.

So what should it do.

1/ Originally DCACHE_DISCONNECTED didn't really mean much - it's presence
   was only a hint, its absence was a strong statement.
   If the flag is set, the dentry might not be linked to the root.
   If it is clear, it definitely is link through to the root.
   However I think it was used with stronger intent than that.

   Now it seems to mean a little bit more:  If it is set and the dentry
   is hashed, then it must be on the sb->s_anon list.  This is a significant
   which I never noticed (I haven't been watching).  Originally a
   disconnected dentry would be attached (and hashed) to its parent.  Then
   that parent would get its own parent and so on until it was attached all
   the way to the root.  Only then would be start clearing
   DCACHE_DISCONNECTED.  It seems we must clear it sooner now... I wonder if
   that is correct.

   Anyway, the original idea was:
     1/ when you create an anonymous dentry for nfsd, set DCACHE_DISCONNECTED.
     2/ when nfsd sees DCACHE_DISCONNECTED it makes sure there is a
        connection to the root, and only clears DCACHE_DISCONNECTED when
        that connection is certain.
     3/ no-one else should look at DCACHE_DISCONNECTED.

2/ directories always have at most one dentry.  It might be IS_ROOT(), and
   it might be DCACHE_DISCONNECTED.
   non-directories can have multiple dentries, but (and here is where the
   various patches changes things) if there is an IS_ROOT() dentry, it must
   be the only hashed dentry. (IS_ROOT dentries are 'hashed' on the
   s_anon chain).

3/ when nfsd finds an inode, it first tries to get a hashed dentry - any
   hashed dentry.  If necessary (and as a last resort) it will create an
   anonymous dentry.  For directories, an unhashed dentry will do too
   (I think ... not 100% clear on that just now).
   This is d_obtain_alias

4/ When nfsd wants the dentry to have a name - either because it is a
   directory or because 'subtree_check' is set - and finds
   DCACHE_DISCONNECTED is set is find the parent inode and makes sure it has
   a non-DCACHE_DISCONNECTED entry (see 3 and 4).  Once it finds that the
   parent has a non-DCACHE_DISCONNECTED dentry, it clears DCACHE_DISCONNECTED
   on the child.

So what do we have:

  d_obtain_alias:
    finds a hashed alias (or any alias for a directory) and if there
     isn't one, creates an IS_ROOT alias, sets DCACHE_DISCONNECTED, and
     adds to sb->s_anon.
    This is used by various "get_parent" and "get_dentry" routines as you
    would expect.  ceph uses it in  open_root_dentry which seems a bit
    odd - maybe it is OK.

  d_splice_alias
   This is more complicated than it should be - with the complication in
   __d_find_alias.
   It's job is to see if the inode already has an IS_ROOT alias.  If it
   does, it should d_move that alias in place of the one it was given,
   else instantiate the one it was given.
   It doesn't have to look very hard.  A directory will only have one
   dentry, so that one either IS_ROOT or not.
   If a non-directory has an IS_ROOT dentry, it will be the only hashed
   dentry.  So there is no question of preferring non-IS_ROOT dentries.
   If there is one, it will be the only one.

   I'm a bit uncomfortable that d_splice_alias drops all locks before
   calling d_move.  Normally when d_move is called, both directories are
   locked in some way.  In the case the source is not a directory bit
   is the state of being anonymous.  Theoretically two calls to
   d_splice_alias on the same inode could try to d_move the same
   anonymous dentry to two different places, which would be bad.
   So I think some locking is needed there.

 d_materialise_unique
   Not sure what this is for... it looks a lot like d_splice_alias,
   only it is a lot more complicated.  The comments in the code and
   in the original commit sound exactly like d_splice_alias.
   One of these two should certainly go.

   It clears DCACHE_DISCONNECTED which is probably the wrong thing to
   do.

 __d_drop assumes that if DCACHE_DISCONNECTED is set then the dentry
   is hashed to s_anon.  This is wrong - d_splice_alias can invalidate
   this.  It should be testing IS_ROOT().  And IS_ROOT will only ever
   be hashed to s_anon.

So I'm suggesting the following patch as a start.
I'm still worried about the locking for d_move in d_splice_alias,
and I think we can discard d_materialise_unique, but I would
want to understand why it is different first.

NeilBrown

diff --git a/fs/dcache.c b/fs/dcache.c
index 2a6bd9a..a6f1884 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -327,7 +327,7 @@ static struct dentry *d_kill(struct dentry *dentry, struct dentry *parent)
 void __d_drop(struct dentry *dentry)
 {
 	if (!(dentry->d_flags & DCACHE_UNHASHED)) {
-		if (unlikely(dentry->d_flags & DCACHE_DISCONNECTED)) {
+		if (unlikely(IS_ROOT(dentry))) {
 			bit_spin_lock(0,
 				(unsigned long *)&dentry->d_sb->s_anon.first);
 			dentry->d_flags |= DCACHE_UNHASHED;
@@ -565,52 +565,29 @@ EXPORT_SYMBOL(dget_parent);
 /**
  * d_find_alias - grab a hashed alias of inode
  * @inode: inode in question
- * @want_discon:  flag, used by d_splice_alias, to request
- *          that only a DISCONNECTED alias be returned.
+ * @want_discon:  flag, used by d_splice_alias to request
+ *          that only an IS_ROOT alias be returned.
  *
  * If inode has a hashed alias, or is a directory and has any alias,
  * acquire the reference to alias and return it. Otherwise return NULL.
  * Notice that if inode is a directory there can be only one alias and
  * it can be unhashed only if it has no children, or if it is the root
  * of a filesystem.
- *
- * If the inode has an IS_ROOT, DCACHE_DISCONNECTED alias, then prefer
- * any other hashed alias over that one unless @want_discon is set,
- * in which case only return an IS_ROOT, DCACHE_DISCONNECTED alias.
+ * If want_discon is set, then only return an IS_ROOT alias.
  */
 static struct dentry *__d_find_alias(struct inode *inode, int want_discon)
 {
-	struct dentry *alias, *discon_alias;
+	struct dentry *alias;
 
-again:
-	discon_alias = NULL;
 	list_for_each_entry(alias, &inode->i_dentry, d_alias) {
 		spin_lock(&alias->d_lock);
- 		if (S_ISDIR(inode->i_mode) || !d_unhashed(alias)) {
-			if (IS_ROOT(alias) &&
-			    (alias->d_flags & DCACHE_DISCONNECTED)) {
-				discon_alias = alias;
-			} else if (!want_discon) {
-				__dget_dlock(alias);
-				spin_unlock(&alias->d_lock);
-				return alias;
-			}
-		}
-		spin_unlock(&alias->d_lock);
-	}
-	if (discon_alias) {
-		alias = discon_alias;
-		spin_lock(&alias->d_lock);
-		if (S_ISDIR(inode->i_mode) || !d_unhashed(alias)) {
-			if (IS_ROOT(alias) &&
-			    (alias->d_flags & DCACHE_DISCONNECTED)) {
-				__dget_dlock(alias);
-				spin_unlock(&alias->d_lock);
-				return alias;
-			}
+ 		if ((S_ISDIR(inode->i_mode) || !d_unhashed(alias))
+		    && (!want_discon || IS_ROOT(alias))) {
+			__dget_dlock(alias);
+			spin_unlock(&alias->d_lock);
+			return alias;
 		}
 		spin_unlock(&alias->d_lock);
-		goto again;
 	}
 	return NULL;
 }
@@ -1599,9 +1576,9 @@ EXPORT_SYMBOL(d_obtain_alias);
  * @inode:  the inode which may have a disconnected dentry
  * @dentry: a negative dentry which we want to point to the inode.
  *
- * If inode is a directory and has a 'disconnected' dentry (i.e. IS_ROOT and
- * DCACHE_DISCONNECTED), then d_move that in place of the given dentry
- * and return it, else simply d_add the inode to the dentry and return NULL.
+ * If inode and has a 'disconnected' dentry (i.e. IS_ROOT()) then
+ * d_move that in place of the given dentry and return it, else simply
+ * d_add the inode to the dentry and return NULL.
  *
  * This is needed in the lookup routine of any filesystem that is exportable
  * (via knfsd) so that we can build dcache paths to directories effectively.
@@ -1614,11 +1591,10 @@ struct dentry *d_splice_alias(struct inode *inode, struct dentry *dentry)
 {
 	struct dentry *new = NULL;
 
-	if (inode && S_ISDIR(inode->i_mode)) {
+	if (inode) {
 		spin_lock(&inode->i_lock);
 		new = __d_find_alias(inode, 1);
 		if (new) {
-			BUG_ON(!(new->d_flags & DCACHE_DISCONNECTED));
 			spin_unlock(&inode->i_lock);
 			security_d_instantiate(new, inode);
 			d_move(new, dentry);
