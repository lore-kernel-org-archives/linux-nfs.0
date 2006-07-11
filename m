From: "Gomez, Daniel" <dgomez@tigr.ORG>
Subject: Re: nfs-utils-1.0.9 released.
Date: Tue, 11 Jul 2006 11:26:38 -0400
Message-ID: <7F0AA25C9B1706448E8B73DFDD109B31028E5B12@EXCHANGE.TIGR.ORG>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G0K8N-0000Ud-0k
	for nfs@lists.sourceforge.net; Tue, 11 Jul 2006 08:26:47 -0700
Received: from ranger.tigr.org ([192.207.234.252])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G0K8M-000188-Us
	for nfs@lists.sourceforge.net; Tue, 11 Jul 2006 08:26:47 -0700
Received: from EXCHANGE.TIGR.ORG (exch1n [172.17.5.22])
	by ranger.tigr.org (8.13.0/8.13.0/Submit) with ESMTP id k6BFQcxC017567
	for <nfs@lists.sourceforge.net>; Tue, 11 Jul 2006 11:26:38 -0400 (EDT)
To: <nfs@lists.sourceforge.net>
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

Thank you Neil.

I see on the manpages on both redhat and suse where you and what we
mostly run that "Olaf Kirch, <okir@monad.swb.de>" has a dead email
address. I noticed this outdated address, since I sent an email
wondering when the '-z' flag would be supported. Is there any chance you
implimented that in your most recent release?

Thank you for contributions.

-Daniel

-----Original Message-----
From: nfs-bounces@lists.sourceforge.net
[mailto:nfs-bounces@lists.sourceforge.net] On Behalf Of Neil Brown
Sent: Friday, July 07, 2006 8:22 PM
To: nfs@lists.sourceforge.net
Subject: [NFS] nfs-utils-1.0.9 released.



I've just released nfs-utils-1.0.9.
You should be able to find it on sourceforge,
   http://sourceforge.net/project/showfiles.php?group_id=14
kernel.org
   http://www.kernel.org/pub/linux/utils/nfs/
and in git
   git://linux-nfs.org/nfs-utils


- Added 'mount.nfs' utility which can be used as a mount helper
  to mount nfs filesystems.  This requires 
     ./configure --enable-mount

  It is not enabled by default as it does not yet support 'user' mounts.


- Makefile/autoconf tidyups
- No compiles with no warnings
- deleted debian/* at request of debian maintainer
- deleted assorted other unused files
- mountd can be run multi-threaded for configurations with many hundreds
  of clients (mountd -t 20).  Default is single-threaded
- Support for selection NFS version to be exported, and protocol to
  use.  This requires kernel patches that should be in linux 2.6.19.
- Use 65534 rather than -2 for default anon.  This makes no difference
in many
  cases, but is important in some.
- New utility 'rpcdebug' for controlled kernel 'debug' options for nfs
and nfsd.
- nfsstat reports NFSv4 operation statistics that should be available in
  linux 2.6.18.
- assorted other fixes

NeilBrown

Using Tomcat but need to do more? Need to support web services,
security? Get stuff done quickly with pre-integrated technology to make
your job easier Download IBM WebSphere Application Server v.1.0.1 based
on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
