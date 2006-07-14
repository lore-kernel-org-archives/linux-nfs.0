From: Stefan Palme <kleiner@hora-obscura.de>
Subject: disabling caching
Date: Fri, 14 Jul 2006 10:12:32 +0200
Message-ID: <1152864752.28625.30.camel@devel.office.ancoso-development.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G1In2-00009s-I7
	for nfs@lists.sourceforge.net; Fri, 14 Jul 2006 01:12:48 -0700
Received: from moutng.kundenserver.de ([212.227.126.183])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G1In0-0001A7-EG
	for nfs@lists.sourceforge.net; Fri, 14 Jul 2006 01:12:48 -0700
Received: from localhost (localhost [127.0.0.1])
	by smtp.hora-obscura.de (Postfix) with ESMTP id 786DE878038
	for <nfs@lists.sourceforge.net>; Fri, 14 Jul 2006 10:12:43 +0200 (CEST)
Received: from devel.office.ancoso-development.de
	(p54B98F43.dip0.t-ipconnect.de [84.185.143.67])
	(using TLSv1 with cipher RC4-MD5 (128/128 bits))
	(No client certificate requested)
	by smtp.hora-obscura.de (Postfix) with ESMTP id 92874878022
	for <nfs@lists.sourceforge.net>; Fri, 14 Jul 2006 10:12:39 +0200 (CEST)
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


Hello,

I have a ext3-directory exported via NFS to a second linux (2.6.x) box.
This first (exporting) host is a linux-2.6.x host, too.

An application on that second box tries to open a file in that
directory. When this fails, it causes the exporting linux box to 
create the missing file (via an application-internal RPC call). 
After that RPC call the second linux box tries again to read 
this file. Although the file now exists, the open() call still 
returns "no such file or directory". This second try is much 
less than one second after the first try. 

After a few seconds, the open() call on the second box succeeds.
So I guess that caching is the reason for the second open()-call
to fail.

Is there a way to make the second call to open() succeed? 

Thanks i.a.
regards

-stefan-





-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
