From: Neil Brown <neilb@suse.de>
Subject: nfs-utils-1.0.9 released.
Date: Sat, 8 Jul 2006 10:21:45 +1000
Message-ID: <17582.64153.783145.814158@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fz0a3-0005iC-3h
	for nfs@lists.sourceforge.net; Fri, 07 Jul 2006 17:21:55 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Fz0a1-00051p-QV
	for nfs@lists.sourceforge.net; Fri, 07 Jul 2006 17:21:55 -0700
Received: from Relay2.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id 46FFE1EC06
	for <nfs@lists.sourceforge.net>; Sat,  8 Jul 2006 02:21:51 +0200 (CEST)
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
- Use 65534 rather than -2 for default anon.  This makes no difference in many
  cases, but is important in some.
- New utility 'rpcdebug' for controlled kernel 'debug' options for nfs and nfsd.
- nfsstat reports NFSv4 operation statistics that should be available in
  linux 2.6.18.
- assorted other fixes

NeilBrown

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
