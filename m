From: Terry Bates <tbates@mainframe.ca>
Subject: Problem with nfs data caching?
Date: Wed, 25 Feb 2004 13:37:15 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <403D158B.124C2469@mainframe.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Aw6ka-0007fy-MI
	for nfs@lists.sourceforge.net; Wed, 25 Feb 2004 13:39:28 -0800
Received: from wale.mainframe.ca ([209.17.131.74])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1Aw6j8-0002zL-Q9
	for nfs@lists.sourceforge.net; Wed, 25 Feb 2004 13:37:58 -0800
Received: from saturn.mainframe.ca (saturn [10.0.0.254])
	by wale.mainframe.ca (SGI-8.9.3/8.9.3) with SMTP id NAA14547
	for <nfs@lists.sourceforge.net>; Wed, 25 Feb 2004 13:37:17 -0800 (PST)
Received: from park.mainframe.ca ([172.16.130.30])
 by saturn.mainframe.ca (NAVGW 2.5.1.18) with SMTP id M2004022513353218197
 for <nfs@lists.sourceforge.net>; Wed, 25 Feb 2004 13:35:32 -0800
Received: from mainframe.ca (Raimi [172.16.130.10])
	by park.mainframe.ca (SGI-8.9.3/8.9.3) with ESMTP id NAA86686
	for <nfs@lists.sourceforge.net>; Wed, 25 Feb 2004 13:37:16 -0800 (PST)
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

We are experiencing a problem which seems to be related to data caching
on our linux nfs clients;

Using Mental Ray, we render picture to an NFS mounted filesystem (I have
tried both SGI and Auspex file servers).  We have an inhouse application
which we use to view the rendered pictures.  If you attempt to view a
picture which has not completely finished rendering, you get a plain
grey window.  Once that situation has happened, you cannot view that
picture from that machine until you umount and mount that filesystem
again.  You can view it from other machines however.

Most of our machines are running RedHat 7.2 with a 2.4.7-10 kernel and
nfs-utils-0.3.1-13.

I have tried using RedHat 8.0 with a 2.4.18-14, 2.4.20-28, and most
recently 2.6.2 kernel, and nfs-utils-1.0.1-2.  Same result.  Here the
line from the /etc/fstab file for the filesystem that I'm testing on:

holly:/images_temp              /images_temp            nfs
rw,bg,rsize=32768,wsize=32768

I don't have this problem with any of our Irix clients.

Terry











-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
