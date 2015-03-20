Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:40942 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750929AbbCTOuO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Mar 2015 10:50:14 -0400
Date: Fri, 20 Mar 2015 10:50:13 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andrew W Elble <aweits@rit.edu>
Cc: linux-nfs@vger.kernel.org, etmsys@rit.edu,
        Al Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH] NFS: fix BUG() crash in notify_change() with patch to
 chown_common()
Message-ID: <20150320145013.GB2036@fieldses.org>
References: <1424699484-74025-1-git-send-email-aweits@rit.edu>
 <20150223205435.GA28635@fieldses.org>
 <m2iodvivzk.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <m2iodvivzk.fsf@discipline.rit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 20, 2015 at 10:28:31AM -0400, Andrew W Elble wrote:
> 
> Any update/feedback?

If you haven't already: could you resend it, To: Al, and a "Cc:
stable@vger.kernel.org" line?

--b.

> 
> "J. Bruce Fields" <bfields@fieldses.org> writes:
> 
> > Looks OK to me.  I think it would go through Al.--b.
> >
> > Acked-by: J. Bruce Fields <bfields@redhat.com>
> >
> > On Mon, Feb 23, 2015 at 08:51:24AM -0500, Andrew Elble wrote:
> >> We have observed a BUG() crash in fs/attr.c:notify_change(). The crash
> >> occurs during an rsync into a filesystem that is exported via NFS.
> >> 
> >> 1.) fs/attr.c:notify_change() modifies the caller's version of attr.
> >> 2.) 6de0ec00ba8d ("VFS: make notify_change pass ATTR_KILL_S*ID to
> >>     setattr operations") introduced a BUG() restriction such that "no
> >>     function will ever call notify_change() with both ATTR_MODE and
> >>     ATTR_KILL_S*ID set". Under some circumstances though, it will have
> >>     assisted in setting the caller's version of attr to this very
> >>     combination.
> >> 3.) 27ac0ffeac80 ("locks: break delegations on any attribute
> >>     modification") introduced code to handle breaking
> >>     delegations. This can result in notify_change() being re-called. attr
> >>     _must_ be explicitly reset to avoid triggering the BUG() established
> >>     in #2.
> >> 4.) The path that that triggers this is via fs/open.c:chmod_common().
> >>     The combination of attr flags set here and in the first call to
> >>     notify_change() along with a later failed break_deleg_wait()
> >>     results in notify_change() being called again via retry_deleg
> >>     without resetting attr.
> >> 
> >> Solution is to move retry_deleg in chmod_common() a bit further up to
> >> ensure attr is completely reset.
> >> 
> >> There are other places where this seemingly could occur, such as
> >> fs/utimes.c:utimes_common(), but the attr flags are not initially
> >> set in such a way to trigger this.
> >> 
> >> Fixes: 27ac0ffeac80 ("locks: break delegations on any attribute modification")
> >> Reported-by: Eric Meddaugh <etmsys@rit.edu>
> >> Tested-by: Eric Meddaugh <etmsys@rit.edu>
> >> Signed-off-by: Andrew Elble <aweits@rit.edu>
> >> ---
> >>  fs/open.c | 2 +-
> >>  1 file changed, 1 insertion(+), 1 deletion(-)
> >> 
> >> diff --git a/fs/open.c b/fs/open.c
> >> index 33f9cbf2610b..44a3be145bfe 100644
> >> --- a/fs/open.c
> >> +++ b/fs/open.c
> >> @@ -570,6 +570,7 @@ static int chown_common(struct path *path, uid_t user, gid_t group)
> >>  	uid = make_kuid(current_user_ns(), user);
> >>  	gid = make_kgid(current_user_ns(), group);
> >>  
> >> +retry_deleg:
> >>  	newattrs.ia_valid =  ATTR_CTIME;
> >>  	if (user != (uid_t) -1) {
> >>  		if (!uid_valid(uid))
> >> @@ -586,7 +587,6 @@ static int chown_common(struct path *path, uid_t user, gid_t group)
> >>  	if (!S_ISDIR(inode->i_mode))
> >>  		newattrs.ia_valid |=
> >>  			ATTR_KILL_SUID | ATTR_KILL_SGID | ATTR_KILL_PRIV;
> >> -retry_deleg:
> >>  	mutex_lock(&inode->i_mutex);
> >>  	error = security_path_chown(path, uid, gid);
> >>  	if (!error)
> >> -- 
> >> 1.9.2
> >> 
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
> 
> -- 
> Andrew W. Elble
> aweits@discipline.rit.edu
> Infrastructure Engineer, Communications Technical Lead
> Rochester Institute of Technology
> PGP: BFAD 8461 4CCF DC95 DA2C B0EB 965B 082E 863E C912
