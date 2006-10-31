From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: [BUG] All Kerberos mounts stop working,
	restarting rpc.svcgssd helps
Date: Tue, 31 Oct 2006 01:12:48 +0100
Message-ID: <20061031001248.GA19915@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GehGQ-0008MR-Dy
	for nfs@lists.sourceforge.net; Mon, 30 Oct 2006 16:13:58 -0800
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GehGP-0005va-6Y
	for nfs@lists.sourceforge.net; Mon, 30 Oct 2006 16:13:59 -0800
Received: from trofast.ipv6.sesse.net ([2001:700:300:1803:20e:cff:fe36:a766]
	helo=trofast.sesse.net)
	by cassarossa.samfundet.no with esmtp (Exim 4.50) id 1GehGC-0002Uo-Bv
	for nfs@lists.sourceforge.net; Tue, 31 Oct 2006 01:13:44 +0100
Received: from sesse by trofast.sesse.net with local (Exim 3.36 #1 (Debian))
	id 1GehFI-0005DH-00
	for <nfs@lists.sourceforge.net>; Tue, 31 Oct 2006 01:12:48 +0100
To: nfs@lists.sourceforge.net
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

[Please Cc me on any replies, I'm not subscribed to the list]

Hi,

We have a machine here running nfs-utils 1.0.10 serving Kerberos over NFSv4,
and every now and then (typically about once a day, but that varies) mounts
just stop working. rpc.svcgssd still runs, packets fly back and forth, but
mount simply refuses. Restarting rpc.svcgssd fixes the problems
immediately -- hosts mounting NFSv4 non-kerberized work just fine.

I've put up a transcript at
http://home.samfundet.no/~sesse/svcgssd-dying.log.bz2 -- hope you get
something useful out of it. (I guess we'll have to change the keytab now, but
hey :-) ) Only the last few calls in there are buggy; the rest are all good.

/* Steinar */
-- 
Homepage: http://www.sesse.net/

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
