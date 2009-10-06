From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [GIT PULL] Please pull NFS client bugfixes for 2.6.32-rc3
Date: Tue, 06 Oct 2009 15:46:22 -0400
Message-ID: <1254858382.3188.10.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:35044 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932950AbZJFTq7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Oct 2009 15:46:59 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

Please pull from the "bugfixes" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git bugfixes

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/nfs/client.c        |    2 +-
 fs/nfs/nfs4namespace.c |   12 ++++++------
 fs/nfs/super.c         |   35 +++++++++++++++++------------------
 3 files changed, 24 insertions(+), 25 deletions(-)

commit 517be09def6cd7bc231222ee756fde8ea245a6fe
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Oct 6 15:42:20 2009 -0400

    NFSv4: Fix the referral mount code
    
    Fix a typo which causes try_location() to use the wrong length argument
    when calling nfs_parse_server_name(). This again, causes the initialisation
    of the mount's sockaddr structure to fail.
    
    Also ensure that if nfs4_pathname_string() returns an error, then we pass
    that error back up the stack instead of ENOENT.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f4373bf9e67e4a653c8854acd7b02dac9714c98a
Author: Ben Hutchings <ben@decadent.org.uk>
Date:   Tue Oct 6 15:42:18 2009 -0400

    nfs: Avoid overrun when copying client IP address string
    
    As seen in <http://bugs.debian.org/549002>, nfs4_init_client() can
    overrun the source string when copying the client IP address from
    nfs_parsed_mount_data::client_address to nfs_client::cl_ipaddr.  Since
    these are both treated as null-terminated strings elsewhere, the copy
    should be done with strlcpy() not memcpy().
    
    Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit bcd2ea17da6a329a7276cde7286d802f009af332
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Oct 6 15:41:22 2009 -0400

    NFS: Fix port initialisation in nfs_remount()
    
    The recent changeset 53a0b9c4c99ab0085a06421f71592722e5b3fd5f (NFS: Replace
    nfs_parse_ip_address() with rpc_pton()) broke nfs_remount, since the call
    to rpc_pton() will zero out the port number in data->nfs_server.address.
    
    This is actually due to a bug in nfs_remount: it should be looking at the
    port number in nfs_server.port instead...
    
    This fixes bug
       http://bugzilla.kernel.org/show_bug.cgi?id=14276
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit f5855fecda65c1965c894915ace1e086d4925154
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Oct 6 15:40:37 2009 -0400

    NFS: Fix port and mountport display in /proc/self/mountinfo
    
    Currently, the port and mount port will both display as 65535 if you do not
    specify a port number. That would be wrong...
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit c5811dbdd26284d63c19fca618bd740dd10ad53d
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Oct 6 15:40:15 2009 -0400

    NFS: Fix a default mount regression...
    
    With the recent spate of changes, the nfs protocol version will now default
    to 2 instead of 3, while the mount protocol version defaults to 3.
    
    The following patch should ensure the defaults are consistent with the
    previous defaults of vers=3,proto=tcp,mountvers=3,mountproto=tcp.
    
    This fixes the bug
       http://bugzilla.kernel.org/show_bug.cgi?id=14259
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
