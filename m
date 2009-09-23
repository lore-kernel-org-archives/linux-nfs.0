From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [GIT PULL] Please pull the following NFS client cleanups and
 bugfixes...
Date: Wed, 23 Sep 2009 14:40:58 -0400
Message-ID: <1253731259.3014.2.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	dhowells@redhat.com, randy.dunlap@oracle.com,
	Benny Halevy <bhalevy@panasas.com>,
	"Mr. Charles Edward Lever" <Chuck.Lever@oracle.com>,
	Neil Brown <neilb@suse.de>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753203AbZIWSmI@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

Please pull from the "bugfixes" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git bugfixes

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/nfs/client.c            |   13 ++++++--
 fs/nfs/fscache.c           |   25 ++++++++++++--
 fs/nfs/fscache.h           |    6 ++-
 fs/nfs/super.c             |   76 +++++++++++++++++++++++---------------------
 include/linux/sunrpc/xdr.h |    5 ++-
 net/sunrpc/rpc_pipe.c      |    3 +-
 net/sunrpc/xprtsock.c      |    9 +++++
 7 files changed, 89 insertions(+), 48 deletions(-)

commit 2df54806389205d76bc3d1ce8a10cc14889ddec9
Author: David Howells <dhowells@redhat.com>
Date:   Wed Sep 23 14:36:39 2009 -0400

    NFS: Propagate 'fsc' mount option through automounts
    
    Propagate the NFS 'fsc' mount option through NFS automounts of various types.
    
    This is now required as commit:
    
    	commit c02d7adf8c5429727a98bad1d039bccad4c61c50
    	Author: Trond Myklebust <Trond.Myklebust@netapp.com>
    	Date:   Mon Jun 22 15:09:14 2009 -0400
    
    	NFSv4: Replace nfs4_path_walk() with VFS path lookup in a private namespace
    
    uses VFS-driven automounting to reach all submounts barring the root, thus
    preventing fscaching from being enabled on any submount other than the root.
    
    This patch gets around that by propagating the NFS_OPTION_FSCACHE flag across
    automounts.  If a uniquifier is supplied to a mount then this is propagated to
    all automounts of that mount too.
    
    Signed-off-by: David Howells <dhowells@redhat.com>
    [Trond: Fixed up the definition of nfs_fscache_get_super_cookie for the
            case of #undef CONFIG_NFS_FSCACHE]
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 4111d4fde6aa04a2e42c43d0e74593e6144b0f0f
Author: Randy Dunlap <randy.dunlap@oracle.com>
Date:   Wed Sep 23 14:36:38 2009 -0400

    sunrpc/rpc_pipe: fix kernel-doc notation
    
    Fix kernel-doc notation (& warnings) in sunrpc/rpc_pipe.c.
    
    Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 97363c6a4f93a20380b4a9e11f35e27fed68a517
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Sep 23 14:36:38 2009 -0400

    sunrpc: xdr_xcode_hyper helpers cannot presume 64-bit alignment
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 9423a08ad5773d0a7612d434700561dc8346b6d6
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Sep 23 14:36:38 2009 -0400

    NFS: Add nfs_alloc_parsed_mount_data
    
    Allocating nfs_parsed_mount_data and setting up the defaults is nearly
    the same for both nfs and nfs4 mounts.
    
    Both paths seem to use nfs_validate_transport_protocol(), so setting a
    default value for nfs_server.protocol ought to be unnecessary.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 61d0a8e6a8049cea246ee7ec19b042d4ff1f6ef6
Author: Neil Brown <neilb@suse.de>
Date:   Wed Sep 23 14:36:37 2009 -0400

    NFS/RPC: fix problems with reestablish_timeout and related code.
    
    
    [[resending with correct cc:  - "vfs.kernel.org" just isn't right!]]
    
    xprt->reestablish_timeout is used to cause TCP connection attempts to
    back off if the connection fails so as not to hammer the network,
    but to still allow immediate connections when there is no reason to
    believe there is a problem.
    
    It is not used for the first connection (when transport->sock is NULL)
    but only on reconnects.
    
    It is currently set:
    
     a/ to 0 when xs_tcp_state_change finds a state of TCP_FIN_WAIT1
        on the assumption that the client has closed the connection
        so the reconnect should be immediate when needed.
     b/ to at least XS_TCP_INIT_REEST_TO when xs_tcp_state_change
        detects TCP_CLOSING or TCP_CLOSE_WAIT on the assumption that the
        server closed the connection so a small delay at least is
        required.
     c/ as above when xs_tcp_state_change detects TCP_SYN_SENT, so that
        it is never 0 while a connection has been attempted, else
        the doubling will produce 0 and there will be no backoff.
     d/ to double is value (up to a limit) when delaying a connection,
        thus providing exponential backoff and
     e/ to XS_TCP_INIT_REEST_TO in xs_setup_tcp as simple initialisation.
    
    So you can see it is highly dependant on xs_tcp_state_change being
    called as expected.  However experimental evidence shows that
    xs_tcp_state_change does not see all state changes.
    ("rpcdebug -m rpc trans" can help show what actually happens).
    
    Results show:
     TCP_ESTABLISHED is reported when a connection is made.  TCP_SYN_SENT
     is never reported, so rule 'c' above is never effective.
    
     When the server closes the connection, TCP_CLOSE_WAIT and
     TCP_LAST_ACK *might* be reported, and TCP_CLOSE is always
     reported.  This rule 'b' above will sometimes be effective, but
     not reliably.
    
     When the client closes the connection, it used to result in
     TCP_FIN_WAIT1, TCP_FIN_WAIT2, TCP_CLOSE.  However since commit
     f75e674 (SUNRPC: Fix the problem of EADDRNOTAVAIL syslog floods on
     reconnect) we don't see *any* events on client-close.  I think this
     is because xs_restore_old_callbacks is called to disconnect
     xs_tcp_state_change before the socket is closed.
     In any case, rule 'a' no longer applies.
    
    So all that is left are rule d, which successfully doubles the
    timeout which is never rest, and rule e which initialises the timeout.
    
    Even if the rules worked as expected, there would be a problem because
    a successful connection does not reset the timeout, so a sequence
    of events where the server closes the connection (e.g. during failover
    testing) will cause longer and longer timeouts with no good reason.
    
    This patch:
    
     - sets reestablish_timeout to 0 in xs_close thus effecting rule 'a'
     - sets it to 0 in xs_tcp_data_ready to ensure that a successful
       connection resets the timeout
     - sets it to at least XS_TCP_INIT_REEST_TO after it is doubled,
       thus effecting rule c
    
    I have not reimplemented rule b and the new version of rule c
    seems sufficient.
    
    I suspect other code in xs_tcp_data_ready needs to be revised as well.
    For example I don't think connect_cookie is being incremented as often
    as it should be.
    
    Signed-off-by: NeilBrown <neilb@suse.de>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 8a6e5deb8a8caa810fef2c525f5dbea2cfe04a47
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Sep 23 14:36:37 2009 -0400

    NFS: Get rid of the NFS_MOUNT_VER3 and NFS_MOUNT_TCP flags
    
    Keep it in the case of the legacy binary mount interface, but purge it from
    the nfs_server structure.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
