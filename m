From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: inux-next: Tree for July 1
Date: Tue, 01 Jul 2008 20:49:03 -0400
Message-ID: <1214959743.10317.3.camel@localhost>
References: <20080702011434.6fb403d5.sfr@canb.auug.org.au>
	 <200807012236.19400.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	kernel-testers@vger.kernel.org, linux-nfs@vger.kernel.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>,
	"Randy.Dunlap" <rdunlap@xenotime.net>,
	"Mr. Charles Edward Lever" <Chuck.Lever@oracle.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759887AbYGBAtX@vger.kernel.org>
In-Reply-To: <200807012236.19400.rjw@sisk.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2008-07-01 at 22:36 +0200, Rafael J. Wysocki wrote:
> I can't mount NFS shares with this kernel.  I get something of this sort in
> dmesg and it seems to be 100% reproducible:
> 
> [  314.058858] RPC: Registered udp transport module.
> [  314.058863] RPC: Registered tcp transport module.
> [  314.490970] RPC: transport (0) not supported
> [  319.246987] __ratelimit: 23 messages suppressed

Does this patch fix the problem for you?
-----------------------------------------------------------------------------------
From: Trond Myklebust <Trond.Myklebust@netapp.com>
NFS: Fix the mount protocol defaults for binary mounts

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/super.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index e09b1c2..85fbb98 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1575,6 +1575,7 @@ static int nfs_validate_mount_data(void *options,
 
 		if (!(data->flags & NFS_MOUNT_TCP))
 			args->nfs_server.protocol = XPRT_TRANSPORT_UDP;
+		nfs_set_transport_defaults(args);
 		/* N.B. caller will free nfs_server.hostname in all cases */
 		args->nfs_server.hostname = kstrdup(data->hostname, GFP_KERNEL);
 		args->namlen		= data->namlen;


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
