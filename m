From: "Aaron D. Ball" <adb@bdi.com>
Subject: append-only attribute support
Date: Fri, 21 Jan 2005 12:56:15 -0500
Message-ID: <41F1423F.3080800@bdi.com>
References: <8381054C-6B13-11D9-BFA6-000D933B35AA@bdi.com>	 <1106318654.3200.38.camel@tribesman.namesys.com>	 <1106322787.30627.5.camel@lade.trondhjem.org>  <41F12C75.5040007@bdi.com> <1106327280.9849.32.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cs30C-0002o7-3g
	for nfs@lists.sourceforge.net; Fri, 21 Jan 2005 09:55:20 -0800
Received: from shinjuku.bdi.com ([63.124.198.36])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.41)
	id 1Cs30A-0006nz-Gj
	for nfs@lists.sourceforge.net; Fri, 21 Jan 2005 09:55:19 -0800
Received: from red-herring.bdi.com ([65.194.110.56])
	by shinjuku.bdi.com with esmtp (Exim 4.34 #1 (Debian))
	id 1Cs2tg-0007t3-Re
	for <nfs@lists.sourceforge.net>; Fri, 21 Jan 2005 12:48:39 -0500
To: nfs@lists.sourceforge.net
In-Reply-To: <1106327280.9849.32.camel@lade.trondhjem.org>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

knfsd as of Linux 2.6.10 refuses to have anything to do with files or 
directories with the append-only attribute set:  not even read 
operations are allowed.  While I understand that NFS doesn't support the 
idea of appending to files, it seems like there should at least be read 
and mkdir support for append-only files and directories, and that this 
could be implemented with a couple small changes to the logic of 
fs/nfsd/vfs.c.

Does that seem reasonable?  Is it likely to happen soon?  Should I try 
to work up a patch?

Though I haven't tested this, it looks like a one-line fix at first glance:

--- vfs.c~      2004-12-24 16:34:31.000000000 -0500
+++ vfs.c       2005-01-21 12:52:14.000000000 -0500
@@ -658,7 +658,7 @@
         * with mandatory locking enabled
         */
        err = nfserr_perm;
-       if (IS_APPEND(inode) || IS_ISMNDLK(inode))
+       if ((IS_APPEND(inode) || (access & MAY_WRITE)) || 
IS_ISMNDLK(inode))
                goto out;
        if (!inode->i_fop)
                goto out;



-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
