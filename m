From: Matt Schillinger <mschilli@vss.fsi.com>
Subject: exportfs operations hang
Date: 17 Jun 2003 14:46:17 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1055879177.10166.3.camel@mosix>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from adsl-66-136-174-212.dsl.stlsmo.swbell.net ([66.136.174.212] helo=esds.vss.fsi.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19SMPA-0002Bl-00
	for <nfs@lists.sourceforge.net>; Tue, 17 Jun 2003 12:46:08 -0700
Received: from mosix.vss.fsi.com (mosix [198.51.27.89])
	by esds.vss.fsi.com (8.11.6+Sun/8.9.1) with ESMTP id h5HJk1K19013
	for <nfs@lists.sourceforge.net>; Tue, 17 Jun 2003 14:46:01 -0500 (CDT)
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hello,

I am having reproducible problems with exportfs.

When I try to run exportfs or exportfs -u, it simply stalls and never
drops back to commandline.. if i CTRL+C, i see that (in the case of an
exportfs) the mountpoint is still not shared. In the case of an exportfs
-u, If i CTRL+C it, the mountpoint IS still shared.  I do not know what
is causing the problem.. the only workaround that I have found is to
restart nfsd.. Is there something in rmtab/xtab/etab that could cause an
exportfs hangup?

I am using 64 threads, and am having no thread utilization issues
according to /proc/net/rpc/nfsd

Has anyone else had this problem?

Thanks for your help
-- 
Matt Schillinger
System Administrator
FlightSafety International
mschilli@vss.fsi.com
314-551-8403




-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
