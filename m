From: "Damien \"Zaide\"" <list@zaide.org>
Subject: NFS changement between 2.6.9 and 2.6.10?
Date: Wed, 26 Jan 2005 11:44:03 +0100
Message-ID: <41F77473.70501@zaide.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ctkeo-0006Xq-Nr
	for nfs@lists.sourceforge.net; Wed, 26 Jan 2005 02:44:18 -0800
Received: from postfix4-1.free.fr ([213.228.0.62])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1Ctken-0000aJ-9E
	for nfs@lists.sourceforge.net; Wed, 26 Jan 2005 02:44:18 -0800
Received: from [192.168.2.9] (diderot-4-81-57-120-45.fbx.proxad.net [81.57.120.45])
	by postfix4-1.free.fr (Postfix) with ESMTP id 88EEB271007
	for <nfs@lists.sourceforge.net>; Wed, 26 Jan 2005 11:44:16 +0100 (CET)
To: nfs@lists.sourceforge.net
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

hi,
I have a nfsV3 server running linux 2.6.9, all is good when I "ls -alR" 
my nfs exported directory on my client after I chroot() in this 
directory and ls -alR too that well.
But when i update my server to linux 2.6.10 and "ls -alR" my nfs 
directory is allways good but when I chroot() inside, my chroot command 
is locked and I can't ls my nfs directory.
I have launch a sniffer and the packet seams to be send.
Do you have any informations about this? a changement beetwen 2.6.9 and 
2.6.10? a patch? a bug?


-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
