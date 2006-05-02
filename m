From: John McFerran <jmcferran@rodgers.rain.com>
Subject: re: exported directories' ownership changing.
Date: Tue, 02 May 2006 14:40:27 -0700
Message-ID: <4457D1CB.6020808@rodgers.rain.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Fb2bj-0005Jg-Po
	for nfs@lists.sourceforge.net; Tue, 02 May 2006 14:40:35 -0700
Received: from rodgerstech.com ([65.121.84.243])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Fb2bi-0003qe-KB
	for nfs@lists.sourceforge.net; Tue, 02 May 2006 14:40:35 -0700
Received: from rodgers.rain.com (216-99-205-82.cust.aracnet.com [216.99.205.82])
	by rodgerstech.com (8.12.11/8.12.11) with ESMTP id k42LeRmW021283
	for <nfs@lists.sourceforge.net>; Tue, 2 May 2006 14:40:28 -0700
Received: from storm.localnet (storm [192.168.200.7])
	by rodgers.rain.com (8.11.6/8.11.6) with ESMTP id k42LeRI22367
	for <nfs@lists.sourceforge.net>; Tue, 2 May 2006 14:40:27 -0700
Received: from [192.168.200.37] (mcf-ws.localnet [192.168.200.37])
	by storm.localnet (8.12.8/8.12.8) with ESMTP id k42LeQd8001266
	for <nfs@lists.sourceforge.net>; Tue, 2 May 2006 14:40:26 -0700
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

Nevermind.

It's not NFS its cron.hourly/msec that changes ownerships without my 
permission,
- some underdocumented security hole patcher courtesy of Mandrake.




-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
