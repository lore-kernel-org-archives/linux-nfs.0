From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 12/17] mount.nfs: Change *flags to flags
Date: Mon, 16 Jul 2007 13:57:57 +1000
Message-ID: <18074.60613.359354.119674@notabene.brown>
References: <20070716031549.11209.79977.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IAHic-000661-T6
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 20:57:54 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IAHif-0007Ps-6q
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 20:57:58 -0700
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
> It's not necessary to treat the *flags parameter to nfsmount and nfs4mount
> as an output parameter.  Nothing is passed back.  Replace it with a normal
> call-by-value.

And, in fact, very little is passed forward.
nfs4mount doesn't use 'flags' at all... maybe it should?
nfsmount uses it for one thing - checking in MS_REMOUNT was set.
So maybe we should change the name to 'remount' and pass down
'flags & MS_REMOUNT' ??

Most of the stuff the nfsmount doesn't do if MS_REMOUNT is talking to
mountd which obviously is not relevant for NFSv4.  But NFSv4 still
tries to ping the server... Should that be excluded in MS_REMOUNT is
set, do you think?

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
