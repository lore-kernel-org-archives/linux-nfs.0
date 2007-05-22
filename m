From: Neil Brown <neilb@suse.de>
Subject: Re: 2.6.22-rc2 built on ppc
Date: Tue, 22 May 2007 15:40:50 +1000
Message-ID: <18002.33378.2388.800348@notabene.brown>
References: <20070520112557.GK3253@aragorn.home.lxtec.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	nfs@lists.sourceforge.net
To: Elimar Riesebieter <riesebie@lxtec.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HqN7Q-0003KR-CP
	for nfs@lists.sourceforge.net; Mon, 21 May 2007 22:41:12 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HqN7S-000082-Rg
	for nfs@lists.sourceforge.net; Mon, 21 May 2007 22:41:15 -0700
In-Reply-To: message from Elimar Riesebieter on Sunday May 20
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

On Sunday May 20, riesebie@lxtec.de wrote:
> Hi,
> 
> FYI, building the kernel modules with
> gcc (GCC) 4.1.3 20070514 (prerelease) (Debian 4.1.2-7)
> on my powerbook (PPC) gives:
> 
> ...
> fs/nfsd/nfs4acl.c: In function '_posix_to_nfsv4_one':
> fs/nfsd/nfs4acl.c:227: warning: 'pas.owner' may be used uninitialized in this function
> fs/nfsd/nfs4acl.c:227: warning: 'pas.group' may be used uninitialized in this function
> fs/nfsd/nfs4acl.c:227: warning: 'pas.other' may be used uninitialized in this function
> ...

Yes....
The reality is that these fields will not be used uninitialised.  This
is because every 'posix_acl' always has an ACL_USER_OBJ, and
ACL_GROUP_OBJ, and an ACL_OTHER.  Isn't it Bruce ??

Maybe we could set all three to zero at the top of
summarize_posix_acl, but doing that just to get the compiler to be
quite is sometimes frowned upon.

Bruce?  Do you have an opinion?

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
