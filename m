From: NeilBrown <neilb@suse.de>
Subject: [PATCH 000 of 19] knfsd: lockd improvements
Date: Fri, 1 Sep 2006 14:38:02 +1000
Message-ID: <20060901141639.27206.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Olaf Kirch <okir@suse.de>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GJ0nF-0005jy-Pl
	for nfs@lists.sourceforge.net; Thu, 31 Aug 2006 21:38:13 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GJ0nE-0004Ee-Oe
	for nfs@lists.sourceforge.net; Thu, 31 Aug 2006 21:38:14 -0700
To: Andrew Morton <akpm@osdl.org>
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

Following 19 patches are reviewed and revised versions of
some of a series of patches that Olaf Kirch posted to the
nfs list a few weeks ago.

They are suitable for 2.6.19.

They have been in the SuSE kernel (in a few different forms)
for quite some time and so have received a fair amount of testing,
though some of the code here is inevitably quite new (it needs
to be just to keep up with the ever-changing kernel ;-)

Apart from a few issues that I have posted about on the 
nfs list, the only changes I have made are enhancing a few
change logs, modifying a couple of comments, removing some dead code,
and adding the odd module parameter to parallel a new sysctl.

This set does *not* include the in-kernel implementation of statd that
came at the end of Olaf's series.  I think that is a big enough change
that it deserves a separate posting, and I haven't finished my review
of it yet anyway :-)

The main item of functionality provided by this set of patches
it to enable lock to identify peer by name instead of by IP address.
This can be important for multi-homed machines.  This is an
option only and must be explicitly selected by a sysctl or
module parameter.  The default is to use IP addresses, which
is generally safer if no multi-homed hosts are present.

This functionality is spread over several patches (there is a fair
bit of infrastructure needed) and there are a lot of clean-ups and
a few minor bug fixes as well.

This patch set compiles and passes basic locking tests (both client
side and server side).
I haven't yet tested the various client-reboot and server-reboot
handling as they are a little harder to test.

If anyone out there is in a position to easily run the connectathon
locking tests on a kernel with these patches..... :-)

 [PATCH 001 of 19] knfsd: Hide use of lockd's h_monitored flag
 [PATCH 002 of 19] knfsd: Consolidate common code for statd->lockd notification
 [PATCH 003 of 19] knfsd: When looking up a lockd host, pass hostname & length
 [PATCH 004 of 19] knfsd: lockd: introduce nsm_handle
 [PATCH 005 of 19] knfsd: Misc minor fixes, indentation changes
 [PATCH 006 of 19] knfsd: lockd: Make nlm_host_rebooted use the nsm_handle
 [PATCH 007 of 19] knfsd: lockd: make the nsm upcalls use the nsm_handle
 [PATCH 008 of 19] knfsd: lockd: make the hash chains use a hlist_node
 [PATCH 009 of 19] knfsd: lockd: Change list of blocked list to list_node
 [PATCH 010 of 19] knfsd: Change nlm_file to use a hlist
 [PATCH 011 of 19] knfsd: lockd: make nlm_traverse_* more flexible
 [PATCH 012 of 19] knfsd: lockd: Add nlm_destroy_host
 [PATCH 013 of 19] knfsd: Simplify nlmsvc_invalidate_all
 [PATCH 014 of 19] knfsd: lockd: optionally use hostnames for identifying peers
 [PATCH 015 of 19] knfsd: make nlmclnt_next_cookie SMP safe
 [PATCH 016 of 19] knfsd: match GRANTED_RES replies using cookies
 [PATCH 017 of 19] knfsd: Export nsm_local_state to user space via sysctl
 [PATCH 018 of 19] knfsd: lockd: fix use of h_nextrebind
 [PATCH 019 of 19] knfsd: Register all RPC programs with portmapper by default

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
