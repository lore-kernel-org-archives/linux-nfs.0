From: "Murata, Dennis" <DENNIS.MURATA@saic.com>
Subject: Anecdotal evidence Linux nfs capability
Date: Fri, 1 Dec 2006 10:06:43 -0800
Message-ID: <56D01C1B776AEE4385D29F25E83E515C0873F485@0599-its-exmb02.us.saic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GqCnt-0006Nu-Ie
	for nfs@lists.sourceforge.net; Fri, 01 Dec 2006 10:08:05 -0800
Received: from cpmx.mail.saic.com ([139.121.17.160]
	ident=[U2FsdGVkX198O0/rnY7O+t6FKjj3tpB1y+7DJJbMT6g=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GqCnt-0004SK-PC
	for nfs@lists.sourceforge.net; Fri, 01 Dec 2006 10:08:07 -0800
Received: from 0599-its-ieg01.mail.saic.com ([139.121.18.36] [139.121.18.36])
	by cpmx.mail.saic.com for nfs@lists.sourceforge.net;
	Fri, 1 Dec 2006 10:07:54 -0800
Received: from cp-its-exbh01.mail.saic.com ([139.121.18.36])
	by 0599-its-ieg01.mail.saic.com (SMSSMTP 4.0.5.66) with SMTP id
	M2006120110075402349
	for <nfs@lists.sourceforge.net>; Fri, 01 Dec 2006 10:07:54 -0800
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

We are in the process of configuring a Linux nfs server.  The hardware
platform is a Dell Poweredge 2850, dual Xeon 3.6Ghz, 6GB memory running RHEL
4 update 2.  The number of clients using the server will be ~1000 x86_64
dual processor opteron workstations.  The data that will be accessed will be
95% read only, possible more like 99% read only, that will consist of mainly
executables, i.e. not large multi-gigabyte data files.
I am trying to gather evidence that the Linux nfs server should be able/not
able to handle the workload.  I would really appreciate it if anyone with
large installations would post what they have and average nfsopts for their
nfs servers.  We will not be using a server farm, so I am interested in
nfsopts per server.

Thanks
Wayne  

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
