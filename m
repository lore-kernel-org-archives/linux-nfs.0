From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [GIT PULL] Please pull 2 more bugfixes for the NFS client
Date: Thu, 24 Sep 2009 15:49:59 -0400
Message-ID: <1253821799.10290.27.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Jaswinder Singh Rajput <jaswinder@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754660AbZIXTuU@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

Please pull from the "bugfixes" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git bugfixes

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/nfs/super.c    |    2 ++
 net/sunrpc/clnt.c |    5 +++--
 2 files changed, 5 insertions(+), 2 deletions(-)

commit 36dd2fdb37efdab15844eb72026f8ce3aa0fb560
Author: Al Viro <viro@ZenIV.linux.org.uk>
Date:   Thu Sep 24 14:58:42 2009 -0400

    nfs[23] tcp breakage in mount with binary options
    
    We forget to set nfs_server.protocol in tcp case when old-style binary
    options are passed to mount.  The thing remains zero and never validated
    afterwards.  As the result, we hit BUG in fs/nfs/client.c:588.
    
    Breakage has been introduced in NFS: Add nfs_alloc_parsed_mount_data
    merged yesterday...
    
    Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7a73fdde3990ea840b604248362876437ea8ce80
Author: Jaswinder Singh Rajput <jaswinder@kernel.org>
Date:   Thu Sep 24 14:58:42 2009 -0400

    net: fix htmldocs sunrpc, clnt.c
    
    
      DOCPROC Documentation/DocBook/networking.xml
      Warning(net/sunrpc/clnt.c:647): No description found for parameter 'req'
      Warning(net/sunrpc/clnt.c:647): No description found for parameter 'tk_ops'
      Warning(net/sunrpc/clnt.c:647): Excess function parameter 'ops' description in 'rpc_run_bc_task'
    
    Signed-off-by: Jaswinder Singh Rajput <jaswinderrajput@gmail.com>
    Cc: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
    Cc: Benny Halevy <bhalevy@panasas.com>
    Cc: Andy Adamson <andros@netapp.com>
    Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: Randy Dunlap <randy.dunlap@oracle.com>
    Cc: David Miller <davem@davemloft.net>
    Acked-by: Randy Dunlap <randy.dunlap@oracle.com>
    Acked-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
