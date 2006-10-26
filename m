From: glogow@fbihome.de
Subject: NFSroot using NFSv4?
Date: Thu, 26 Oct 2006 13:15:13 +0200
Message-ID: <1161861313.454098c141626@stud.fbi.h-da.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gd3Co-0001Wj-4b
	for nfs@lists.sourceforge.net; Thu, 26 Oct 2006 04:15:28 -0700
Received: from stud.fbi.fh-darmstadt.de
	([141.100.40.65] helo=fbihome.de ident=postfix)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Gd3Ck-0004Tl-Sr
	for nfs@lists.sourceforge.net; Thu, 26 Oct 2006 04:15:27 -0700
Received: from localhost (localhost [127.0.0.1])
	by fbihome.de (Postfix) with ESMTP id 12DF9932D0
	for <nfs@lists.sourceforge.net>; Thu, 26 Oct 2006 13:15:14 +0200 (CEST)
Received: from fbihome.de ([127.0.0.1])
	by localhost (stud1 [127.0.0.1]) (amavisd-new, port 10024) with ESMTP
	id 09796-06 for <nfs@lists.sourceforge.net>;
	Thu, 26 Oct 2006 13:15:13 +0200 (CEST)
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

Hi

I'm looking for some information on using Linux kernel NFSroot with NFSv4.

>From reading some documentation it seems that there are some additional daemons
involved to mount NFSv4 exports on a client (idmapd, gssd (just for krb5?)).

Is it possible to run NFSv4 as a read-only NFSroot, without an initrd /
initramfs, which would otherwise start these deamons and use a NFSv4 enabled
mount and a pivot_root?

I don't need any security features of NFSv4, as it would just be used for
installing Debain via PXE and FAI.

Thanks

Jan-Marek

----------------------------------------------------------------
This message was sent using IMP, the Internet Messaging Program.

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
