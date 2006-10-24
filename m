From: Evert <evert@poboxes.info>
Subject: bad connection?
Date: Tue, 24 Oct 2006 15:16:48 +0200
Message-ID: <0bg114-bqv.ln1@poboxes.info>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GcMRH-0002Fo-HG
	for nfs@lists.sourceforge.net; Tue, 24 Oct 2006 06:35:31 -0700
Received: from main.gmane.org ([80.91.229.2] helo=ciao.gmane.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GcMRG-0004dv-Uq
	for nfs@lists.sourceforge.net; Tue, 24 Oct 2006 06:35:32 -0700
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1GcMQo-0001ya-So
	for nfs@lists.sourceforge.net; Tue, 24 Oct 2006 15:35:02 +0200
Received: from i165182.directconnect.no ([82.148.165.182])
	by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
	id 1AlnuQ-0007hv-00
	for <nfs@lists.sourceforge.net>; Tue, 24 Oct 2006 15:35:02 +0200
Received: from evert by i165182.directconnect.no with local (Gmexim 0.1
	(Debian)) id 1AlnuQ-0007hv-00
	for <nfs@lists.sourceforge.net>; Tue, 24 Oct 2006 15:35:02 +0200
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

I see a LOT of messages like the following in dmesg:

********************************************************
 nfs: server 192.168.240.140 not responding, still trying
 nfs: server 192.168.240.140 not responding, still trying
 nfs: server 192.168.240.140 OK
 nfs: server 192.168.240.140 OK
 nfs: server 192.168.240.140 not responding, still trying
 nfs: server 192.168.240.140 not responding, still trying
 nfs: server 192.168.240.140 not responding, still trying
 nfs: server 192.168.240.140 not responding, still trying
 nfs: server 192.168.240.140 OK
 nfs: server 192.168.240.140 OK
 nfs: server 192.168.240.140 OK
 nfs: server 192.168.240.140 OK
 nfs: server 192.168.240.140 not responding, still trying
 nfs: server 192.168.240.140 not responding, still trying
 nfs: server 192.168.240.140 OK
 nfs: server 192.168.240.140 not responding, still trying
 nfs: server 192.168.240.140 not responding, still trying
 nfs: server 192.168.240.140 OK
 nfs: server 192.168.240.140 OK
 nfs: server 192.168.240.140 OK
 nfs: server 192.168.240.140 not responding, still trying
 nfs: server 192.168.240.140 not responding, still trying
 nfs: server 192.168.240.140 OK
 nfs: server 192.168.240.140 OK
 nfs: server 192.168.240.140 not responding, still trying
 nfs: server 192.168.240.140 OK
 nfs: server 192.168.240.140 not responding, still trying
 nfs: server 192.168.240.140 OK
********************************************************

What could the problem be? This NFS-link is very slow some times, even
though there's enough (640k/640k) bandwidth...

  Evert


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
