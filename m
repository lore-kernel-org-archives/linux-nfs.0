From: "Alex Pavloff" <apavloff@esatechnology.com>
Subject: Problems connectinh to Microsoft Services for Unix 3.0 NFS server
Date: Thu, 9 Oct 2003 11:32:33 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <662C51BFF387D9459C4281CD9A3F9D639F4B@tiber.internal.esatechnology.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A7faV-0006Ez-00
	for <nfs@lists.sourceforge.net>; Thu, 09 Oct 2003 11:32:35 -0700
Received: from eth0.a.smtp.sonic.net ([64.142.16.244])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.22)
	id 1A7faU-0007SR-21
	for nfs@lists.sourceforge.net; Thu, 09 Oct 2003 11:32:34 -0700
Received: from tiber.internal.esatechnology.com (adsl-64-142-24-242.sonic.net [64.142.24.242])
	by eth0.a.smtp.sonic.net (8.12.10/8.12.7) with ESMTP id h99IWXXN023873
	for <nfs@lists.sourceforge.net>; Thu, 9 Oct 2003 11:32:33 -0700
To: <nfs@lists.sourceforge.net>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


Hi folks,=20

I've been trying to figure out why I can't connect my Redhat 8.0 client
to my Services for Unix 3.0 server.

My Redhat 7.0 box (RH kernel 2.2.16 and nfs-utils 0.1.9) works just
fine.
My embedded system (stock kernel 2.4.20 and nfs-utils 0.3.3) works just
fine.
My Redhat 8.0 box (latest RH kernel 2.4.20, stock nfs-utils and
nfs-utils 1.0.6) hangs on mount.

The Windows box reports a successful mount, and since the other machines
can mount just fine, I don't think that the problem is Windows.

Linux reports that the server times out, returns getattr =3D 5, and =
strace
shows that the mount command hangs in mount().

Any ideas or suggestions to get this going?

Thanks!

Alex Pavloff - apavloff@esatechnology.com
ESA Technology ---- www.esatechnology.com
------- Linux-based industrial HMI ------
-------- www.esatechnology.com/5k -------


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
SourceForge.net hosts over 70,000 Open Source Projects.
See the people who have HELPED US provide better services:
Click here: http://sourceforge.net/supporters.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
