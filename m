From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 0/6] nfs-utils: add IPv6 support for rpc.nfsd (try #4)
Date: Tue,  2 Jun 2009 07:43:43 -0400
Message-ID: <1243943029-6400-1-git-send-email-jlayton@redhat.com>
Cc: steved@redhat.com, chuck.lever@oracle.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:42908 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757205AbZFBLn6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Jun 2009 07:43:58 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is the fourth attempt at a patchset to add IPv6 support to the
rpc.nfsd program. This set is quite a bit different from the earlier
ones. The main differences are:

1) it first walks /etc/netconfig to determine the protocols and address
families to enable. Then disables any specified by command line options.

2) it uses getaddrinfo to generate sockaddrs for sockets that get passed
off to the kernel. This simplifies the code quite a bit and makes for
more robust handling of the -H option.

3) converts nfsd to use xlog logging facility. It also adds a --debug
option that causes it to log to stderr rather than syslog, and makes it
print out all debug messages.

4) in the event that an ipv6-enabled rpc.nfsd is run on a kernel that
doesn't have an ipv6-enabled knfsd, the program doesn't log an error
message if it's able to start nfsd on an IPv4 socket. This should cut
down spurious logging until IPv6 support is more widely available.

There is also a lot of general cleanup and reorganization of the startup
logic. Although this patchset is a bit larger than the prior ones, I
think the result is a much cleaner set of code.

This set should be bisectable, but I've only really tested the final
result. I have tested it on various combinations of build options and
with ipv6.ko blacklisted and it seems to work appropriately in all
cases.

Jeff Layton (6):
  nfs-utils: don't link libexport.a and libmisc.a to nfsd
  nfs-utils: clean up option parsing in nfsd.c
  nfs-utils: break up nfssvc.c into more individually callable
    functions
  nfs-utils: set IPV6_V6ONLY on nfssvc IPv6 sockets
  nfs-utils: add IPv6 support to nfsd
  nfs-utils: update the nfsd manpage

 support/include/nfs/nfs.h |   15 ++-
 support/include/nfslib.h  |    7 +-
 support/nfs/nfssvc.c      |  231 ++++++++++++++++++++++++++++---------------
 utils/nfsd/Makefile.am    |    4 +-
 utils/nfsd/nfsd.c         |  243 +++++++++++++++++++++++++++++++++------------
 utils/nfsd/nfsd.man       |   19 +++-
 6 files changed, 365 insertions(+), 154 deletions(-)

