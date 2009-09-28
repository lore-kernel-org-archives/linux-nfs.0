From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: NFS problem with past 2.6.31 git tree
Date: Mon, 28 Sep 2009 13:50:02 -0400
Message-ID: <1254160202.7124.2.camel@heimdal.trondhjem.org>
References: <c4e36d110909250812g74e049b7u39566d189970d77e@mail.gmail.com>
	 <1253892426.31072.37.camel@heimdal.trondhjem.org>
	 <c4e36d110909251246s6af618e8n663afe2b66c4cd5d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org
To: Zdenek Kabelac <zdenek.kabelac@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752441AbZI1Rut@vger.kernel.org>
In-Reply-To: <c4e36d110909251246s6af618e8n663afe2b66c4cd5d@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-09-25 at 21:46 +0200, Zdenek Kabelac wrote:
> 2009/9/25 Trond Myklebust <Trond.Myklebust@netapp.com>:
> > On Fri, 2009-09-25 at 17:12 +0200, Zdenek Kabelac wrote:
> >> Hi
> >>
> >> I've noticed that my qemu guest is now unable to use localy exported
> >> nfs directory.
> >> Directory gets mounted, plain 'ls' shows filenames - but nothing else
> >> could be done.
> >>
> >> ls -la gives this output:
> >> ls: cannot access patch: Input/output error
> >> ...
> >>
> >>
> >> Both host & guest are running same kernel:
> >> 851b147e4411df6a1e7e90e2a609773c277eefd2
> >>
> >> I've checked last few commits and tried to revert them -
> >> and this one seems to cure my problem when reverted:
> >>
> >> Sep 23:  8a6e5deb8a8caa810fef2c525f5dbea2cfe04a47
> >> NFS: Get rid of the NFS_MOUNT_VER3 and NFS_MOUNT_TCP flags
> >>
> >> I should also probably note that I'm seeing this message in my dmesg log:
> >> svc: failed to register lockdv1 RPC service (errno 97)
> >>
> >> rpcinfo -p
> >>    program vers proto   port
> >>     100000    2   tcp    111  portmapper
> >>     100000    2   udp    111  portmapper
> >>     100024    1   udp  53550  status
> >>     100024    1   tcp  44174  status
> >>     100021    1   udp  49878  nlockmgr
> >>     100021    3   udp  49878  nlockmgr
> >>     100021    4   udp  49878  nlockmgr
> >>     100021    1   tcp  47319  nlockmgr
> >>     100021    3   tcp  47319  nlockmgr
> >>     100021    4   tcp  47319  nlockmgr
> >>
> >> automount(pid1720) /misc autofs
> >> rw,relatime,fd=4,pgrp=1720,timeout=300,minproto=2,maxproto=4,indirect
> >> 0 0
> >> 192.168.122.1:/home/u/export /misc/u nfs
> >> rw,relatime,vers=3,rsize=524288,wsize=524288,namlen=255,soft,proto=tcp,port=65535,timeo=600,retrans=2,sec=sys,mountaddr=192.168.xxx.yyy,mountvers=3,mountproto=tcp,addr=192.168.xxx.yyy
> >> 0 0
> >>
> >>
> >> Zdenek
> > What does
> >
> >   cat /proc/self/mountinfo
> >
> > give you?
> >
> 
> 
> Working version: (kernel 2.6.31 or current git with reverted NFS patch)
> 
> 22 12 0:17 / /misc rw,relatime - autofs automount(pid1720)
> rw,fd=4,pgrp=1720,timeout=300,minproto=2,maxproto=4,indirect
> 
> 24 22 0:19 / /misc/kabi rw,relatime - nfs IP:/home/kabi/export
> rw,vers=3,rsize=524288,wsize=524288,namlen=255,soft,proto=tcp,port=65535,timeo=600,retrans=2,sec=sys,mountaddr=IP,mountvers=3,mountproto=tcp,addr=IP
> 
> 
> Nonworking version:
> 
> 22 12 0:17 / /misc rw,relatime - autofs automount(pid1704)
> rw,fd=4,pgrp=1704,timeout=300,minproto=2,maxproto=4,indirect
> 
> 24 22 0:19 / /misc/kabi rw,relatime - nfs IP:/home/kabi/export
> rw,vers=2,rsize=8192,wsize=8192,namlen=255,soft,proto=tcp,port=65535,timeo=600,retrans=2,sec=sys,mountaddr=IP,mountvers=3,mountproto=tcp,addr=IP
> 
> 
> 
> Looks like vers=2  != vers=3   and rsize/wsize - which is also set by
> the kernel itself to those lower values.
> (i.e. my /etc/init.d/autofs doesn't modify localoptions - of course I
> could use this to set 8192 wsize and rsize for my working kernel)
> 
> Zdenek


OK. The following patch fixes the default nfs version issue for me. I
have another one to fix the incorrectly displayed port numbers...

Cheers
  Trond
------------------------------------------------------------------------
NFS: Fix a default mount regression...
From: Trond Myklebust <Trond.Myklebust@netapp.com>

With the recent spate of changes, the nfs protocol version will now default
to 2 instead of 3, while the mount protocol version defaults to 3.

The following patch should ensure the defaults are consistent with the
previous defaults of vers=3,proto=tcp,mountvers=3,mountproto=tcp.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/super.c |   13 ++++++-------
 1 files changed, 6 insertions(+), 7 deletions(-)


diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 29786d3..0343ebc 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -728,22 +728,24 @@ static void nfs_umount_begin(struct super_block *sb)
 	unlock_kernel();
 }
 
-static struct nfs_parsed_mount_data *nfs_alloc_parsed_mount_data(int flags)
+static struct nfs_parsed_mount_data *nfs_alloc_parsed_mount_data(unsigned int version)
 {
 	struct nfs_parsed_mount_data *data;
 
 	data = kzalloc(sizeof(*data), GFP_KERNEL);
 	if (data) {
-		data->flags		= flags;
 		data->rsize		= NFS_MAX_FILE_IO_SIZE;
 		data->wsize		= NFS_MAX_FILE_IO_SIZE;
 		data->acregmin		= NFS_DEF_ACREGMIN;
 		data->acregmax		= NFS_DEF_ACREGMAX;
 		data->acdirmin		= NFS_DEF_ACDIRMIN;
 		data->acdirmax		= NFS_DEF_ACDIRMAX;
+		data->mount_server.port	= NFS_UNSPEC_PORT;
 		data->nfs_server.port	= NFS_UNSPEC_PORT;
+		data->nfs_server.protocol = XPRT_TRANSPORT_TCP;
 		data->auth_flavors[0]	= RPC_AUTH_UNIX;
 		data->auth_flavor_len	= 1;
+		data->version		= version;
 		data->minorversion	= 0;
 	}
 	return data;
@@ -1711,8 +1713,6 @@ static int nfs_validate_mount_data(void *options,
 
 		if (!(data->flags & NFS_MOUNT_TCP))
 			args->nfs_server.protocol = XPRT_TRANSPORT_UDP;
-		else
-			args->nfs_server.protocol = XPRT_TRANSPORT_TCP;
 		/* N.B. caller will free nfs_server.hostname in all cases */
 		args->nfs_server.hostname = kstrdup(data->hostname, GFP_KERNEL);
 		args->namlen		= data->namlen;
@@ -2106,7 +2106,7 @@ static int nfs_get_sb(struct file_system_type *fs_type,
 	};
 	int error = -ENOMEM;
 
-	data = nfs_alloc_parsed_mount_data(NFS_MOUNT_VER3 | NFS_MOUNT_TCP);
+	data = nfs_alloc_parsed_mount_data(3);
 	mntfh = kzalloc(sizeof(*mntfh), GFP_KERNEL);
 	if (data == NULL || mntfh == NULL)
 		goto out_free_fh;
@@ -2376,7 +2376,6 @@ static int nfs4_validate_mount_data(void *options,
 	if (data == NULL)
 		goto out_no_data;
 
-	args->version		= 4;
 	switch (data->version) {
 	case 1:
 		if (data->host_addrlen > sizeof(args->nfs_server.address))
@@ -2660,7 +2659,7 @@ static int nfs4_get_sb(struct file_system_type *fs_type,
 	struct nfs_parsed_mount_data *data;
 	int error = -ENOMEM;
 
-	data = nfs_alloc_parsed_mount_data(0);
+	data = nfs_alloc_parsed_mount_data(4);
 	if (data == NULL)
 		goto out_free_data;
 



-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
