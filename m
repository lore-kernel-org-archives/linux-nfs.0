From: Filipe Brandenburger <branden@terra.com.br>
Subject: rename works? (was: open O_EXCL works?)
Date: Wed, 23 Mar 2005 11:39:03 -0300
Message-ID: <20050323113859.BECF.BRANDEN@terra.com.br>
References: <20050322101843.BE94.BRANDEN@terra.com.br> <1111498903.24016.17.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DE6zE-0008B5-JU
	for nfs@lists.sourceforge.net; Wed, 23 Mar 2005 06:37:32 -0800
Received: from loncoche.terra.com.br ([200.154.55.229])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DE6zB-0001Ek-F3
	for nfs@lists.sourceforge.net; Wed, 23 Mar 2005 06:37:32 -0800
Received: from paramonga.terra.com.br (paramonga.terra.com.br [200.154.55.133])
	by loncoche.terra.com.br (Postfix) with ESMTP id E50A2E78AA6
	for <nfs@lists.sourceforge.net>; Wed, 23 Mar 2005 11:37:26 -0300 (BRT)
Received: from [200.176.1.176] (branden.terra.com.br [200.176.1.176])
	(authenticated user branden)
	by paramonga.terra.com.br (Postfix) with ESMTP id C007D21C012
	for <nfs@lists.sourceforge.net>; Wed, 23 Mar 2005 11:37:26 -0300 (BRT)
To: nfs@lists.sourceforge.net
In-Reply-To: <1111498903.24016.17.camel@lade.trondhjem.org>
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


Hi, there.

I found another problem just now. I have two processes calling "rename"
to move all files from one directory to another, they're both calling
the same actions, for example, if process 1 on client 1 calls
rename("a/x","b/x"), process 2 on client 2 will call rename("a/x","b/x").

Apparently, somehow, I had one process trying to move 120 files (all
that were on directory "a"). It said it managed to move 112 files, 8 of
them failed. The second process entered the directory when there were 17
files, it tried to move them, and reported that moved successfully 16 of
them, 1 of them failed. But that means that both together moved 112 + 16
= 128 files! That "8" files are reflected in my other accounting, that
says there are 8 files more than there really are.

What I mean is, is it possible that both processes called the rename for
the same file, and that both of them succeeded? Is it that the success
of the rename operation depends on the destination file being there
instead of the success of the rename operation itself? If that's it, is
there a way to circumvent this restriction? If I use, for example,
hardlink and unlink, it would solve the concurrency problems?

I can provide more information on the problem upon request.

Thanks again,
Filipe



-------------------------------------------------------
This SF.net email is sponsored by: 2005 Windows Mobile Application Contest
Submit applications for Windows Mobile(tm)-based Pocket PCs or Smartphones
for the chance to win $25,000 and application distribution. Enter today at
http://ads.osdn.com/?ad_id=6882&alloc_id=15148&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
