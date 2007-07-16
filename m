From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 04/17] mount.nfs: /bin/mount already handles
 --bind & friends
Date: Mon, 16 Jul 2007 14:30:32 +1000
Message-ID: <18074.62568.248229.796083@notabene.brown>
References: <20070716031509.11209.35069.stgit@manray.1015granger.net>
	<18074.59805.866117.453406@notabene.brown>
	<469AECC2.9000007@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IAIE8-0000mi-M3
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 21:30:28 -0700
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IAIEB-0003W2-V7
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 21:30:32 -0700
In-Reply-To: message from Chuck Lever on Sunday July 15
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

On Sunday July 15, chuck.lever@oracle.com wrote:
> > 
> > Fair enough - I don't suppose the protocol for how /bin/mount talks to
> > /sbin/mount.$fstype is documented anywhere???  I guess just in the
> > code :-(
> 
> There are rumors that somehow the helpers will turn into plug-ins one 
> day.  But yes, this is ambiguous and somewhat crappy.  I did ask the 
> developers who constructed mount.ocfs2 about this.

Plug-ins sound like a potentially good idea.  The one thing that I
really hate about the current setup is that the helper has to be
setuid root.  Which means that it has no way to know if 'mount' has
sanity checked the options, so it has to do all the checking it self,
and read fstab, which is really dumb.

So, something to look forward to :-)

> 
> Yes.  See the later patch that moves the mount system call to nfsmount.c 
> and nfs4mount.c.

No, I didn't see that...
Oh, there it is.  Patch 11.
"Refactor mount processing slightly...."

I obviously didn't read that patch closely enough.  Makes sense
though.  Thanks.

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
