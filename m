From: =?ISO-8859-15?Q?Sven_K=F6hler?= <skoehler@upb.de>
Subject: export directory under different name
Date: Sat, 25 Sep 2004 21:11:20 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <cj4fts$6mm$1@sea.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CBHxi-0006iy-JF
	for nfs@lists.sourceforge.net; Sat, 25 Sep 2004 12:12:02 -0700
Received: from main.gmane.org ([80.91.229.2])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CBHxh-0002LC-Vz
	for nfs@lists.sourceforge.net; Sat, 25 Sep 2004 12:12:02 -0700
Received: from list by main.gmane.org with local (Exim 3.35 #1 (Debian))
	id 1CBHxf-0003RF-00
	for <nfs@lists.sourceforge.net>; Sat, 25 Sep 2004 21:11:59 +0200
Received: from p508a5865.dip.t-dialin.net ([80.138.88.101])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <nfs@lists.sourceforge.net>; Sat, 25 Sep 2004 21:11:59 +0200
Received: from skoehler by p508a5865.dip.t-dialin.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <nfs@lists.sourceforge.net>; Sat, 25 Sep 2004 21:11:59 +0200
To: nfs@lists.sourceforge.net
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

Hi,

is it possible to export a directory under a different name?
Let's say i have a directory called /mnt/disk1/home3 and other machines 
would like to mount it as if it was /home3. Is this possible? i wouldn't 
know, how an entry in /etc/exports would look like.

The problem is, that i have to adjust my configuration to match an 
existing structure. I must must export the directory /home3, but i don't 
want to mount the whole partition there.

At present, i do a "mount -o bind /mnt/disk1/home3 /home3" which works 
fine *fingers crossed*. Is this a supported configuration, or does this 
only work "by accident"?

Thx
   Sven




-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
