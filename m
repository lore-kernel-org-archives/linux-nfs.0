From: Stuart Anderson <anderson@ligo.caltech.edu>
Subject: Failure to mount from multiple servers in a short period of time
Date: Sun, 30 Jan 2005 20:24:15 -0800
Message-ID: <200501310424.j0V4OF5e000412@m27.ligo.caltech.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CvT6n-00032b-L8
	for nfs@lists.sourceforge.net; Sun, 30 Jan 2005 20:24:17 -0800
Received: from acrux.ligo.caltech.edu ([131.215.115.14])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CvT6m-0004h5-8j
	for nfs@lists.sourceforge.net; Sun, 30 Jan 2005 20:24:17 -0800
Received: from m27.ligo.caltech.edu (m27 [131.215.115.127])
	by acrux.ligo.caltech.edu (8.12.11/8.12.11) with ESMTP id j0V4Ng78001868
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <nfs@lists.sourceforge.net>; Sun, 30 Jan 2005 20:23:42 -0800 (PST)
Received: (from anderson@localhost)
	by m27.ligo.caltech.edu (8.12.8/8.12.8/Submit) id j0V4OF5e000412
	for nfs@lists.sourceforge.net; Sun, 30 Jan 2005 20:24:15 -0800
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

On a dual-Xeon 4GB server running FC3 I am unable to successfully
issue more than 52 automount requests to unique Linux NFS servers
in less than a minute.

After 52 mounts I get the following error. This is reproducible.

Jan 30 10:40:22 beowulf automount[22882]: >> nfs bindresvport: Address
already in use
Jan 30 10:40:22 beowulf automount[22882]: mount(nfs): nfs: mount
failure node54:/usr1 on /data/node54
Jan 30 10:40:22 beowulf automount[22882]: failed to mount /data/node54

After waiting ~1 minute I am able to mount another 52 filesystems
before the getting the same error again.

This limitation is breaking an application on a large Beowulf cluster
that cross-mounts data between 290 GigE attached nodes. I have also
reproduced this problem with a script that explicitly calls
/bin/mount rather than relying on automount.

I tried upgrading to autofs-4.1.4_beta1 to rule out any broken RedHat patches
but that did not help.

This problem does not occur on a RedHat 9 or Solaris 9 client machine.

Any ideas on how to increase the allowed rate of mounts?

Thanks.


-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
