From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: 2.6.22-rc2 built on ppc
Date: Tue, 22 May 2007 13:20:23 -0400
Message-ID: <20070522172023.GE13898@fieldses.org>
References: <20070520112557.GK3253@aragorn.home.lxtec.de>
	<18002.33378.2388.800348@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Elimar Riesebieter <riesebie@lxtec.de>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HqY28-0008Ej-42
	for nfs@lists.sourceforge.net; Tue, 22 May 2007 10:20:28 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HqY28-0001b9-OV
	for nfs@lists.sourceforge.net; Tue, 22 May 2007 10:20:31 -0700
In-Reply-To: <18002.33378.2388.800348@notabene.brown>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Tue, May 22, 2007 at 03:40:50PM +1000, Neil Brown wrote:
> On Sunday May 20, riesebie@lxtec.de wrote:
> > fs/nfsd/nfs4acl.c: In function '_posix_to_nfsv4_one':
> > fs/nfsd/nfs4acl.c:227: warning: 'pas.owner' may be used uninitialized in this function
> > fs/nfsd/nfs4acl.c:227: warning: 'pas.group' may be used uninitialized in this function
> > fs/nfsd/nfs4acl.c:227: warning: 'pas.other' may be used uninitialized in this function
> 
> Yes....
> The reality is that these fields will not be used uninitialised.  This
> is because every 'posix_acl' always has an ACL_USER_OBJ, and
> ACL_GROUP_OBJ, and an ACL_OTHER.  Isn't it Bruce ??

Yeah, note the:

	/* We assume the acl has been verified with posix_acl_valid. */

at the top of _posix_to_nfsv4_one()--as long as that's true, the
warnings are bogus.  Of course, this isn't the sort of thing you'd
expect a compiler to know.  But probably it should know it can't know,
and be quiet.

> Maybe we could set all three to zero at the top of
> summarize_posix_acl, but doing that just to get the compiler to be
> quite is sometimes frowned upon.
> 
> Bruce?  Do you have an opinion?

You've summed it up.

I hate the compile noise too.  If people really wanted the
initialization there, and didn't think it would make the code more
confusing (e.g. by implying the rest of the code should also be dealing
with the case when the ACL_USER_OBJ, ACL_GROUP, or ACL_OTHER entries
weren't there), then I'd be OK with adding it.  Though I'm not
particularly interested in another flamewar about whose fault these
warnings are.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
