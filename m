From: Bruce Allan <bwa@us.ibm.com>
Subject: [PATCH 0/5] initial changes for NFS-over-IPv6
Date: 11 Apr 2003 16:34:29 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1050104071.1413.265.camel@w-bwa1.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: bwa@us.ibm.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from e1.ny.us.ibm.com ([32.97.182.101])
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19482e-0006NN-00
	for <nfs@lists.sourceforge.net>; Fri, 11 Apr 2003 16:34:44 -0700
Received: from northrelay04.pok.ibm.com (northrelay04.pok.ibm.com [9.56.224.206])
	by e1.ny.us.ibm.com (8.12.9/8.12.2) with ESMTP id h3BNYVWn194076
	for <nfs@lists.sourceforge.net>; Fri, 11 Apr 2003 19:34:32 -0400
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

Following are a set of 5 patches against 2.5.66 which provide the
initial ground-work for NFS-over-IPv6 support.  Please keep in mind, NFS
still will not work over IPv6 until comparable support is made available
in the applicable user-space libraries, daemons and utilities
(glibc/sunrpc, nfs-utils, etc.) which I will be working on in the coming
weeks.  Consequently, the IPv6-specific code in these patches have not
been thoroughly tested (IPv4-specific code was, see below), so I expect
to discover bugs once these user-space bits are ready for testing. 
Basically, this set of patches is the first step at getting IPv6 support
for the entire NFS stack.

All patches should be used together with the exception of the last, i.e.
5/5 or linux-2.5.66-NFS_IPv6_Kconfig.dif, which allows for the kernel
config parameter CONFIG_NFS_IPV6.  This is a pre-processor #ifdef that
is used to surround code and data structures used to interact with the
above mentioned user-space code.  Until such user-space NFS-over-IPv6
support is added, it may be better to not include this patch so users
won't see the option when configuring the kernel and assume such support
is available, enable the option and complain when NFS doesn't work
anymore.  Opinions on that?

The patches were applied to a stock 2.5.66 kernel on RH8.0 and were
regression tested with Connectathon '03 and fsx tests with default
options (tcp also) over an IPv4 network to verify nothing had broken. 
The patched kernel was also instrumented with the gcov-2.5.66 code
coverage tool to verify as much as possible of the patched code was
exercised. 

Note, this patch set doesn't provide IPv6 support for nfsroot.

btw while testing the patches, two bugs were discovered, one while
running fsx and the other while running Connectathon '03 over NFSv2. 
Both were found to also exist on stock 2.5.66 and I am not sure whether
they have been reported or being investigated - I'll look into these
further.

Any comments/questions/discussion?

-- 
Bruce Allan
Linux Technology Center
IBM Corporation, Beaverton OR



-------------------------------------------------------
This SF.net email is sponsored by: Etnus, makers of TotalView, The debugger 
for complex code. Debugging C/C++ programs can leave you feeling lost and 
disoriented. TotalView can help you find your way. Available on major UNIX 
and Linux platforms. Try it free. www.etnus.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
