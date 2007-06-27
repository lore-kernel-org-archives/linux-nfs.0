From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Kernel NFS nfs_update_inode Oops in 2.6.20.11
Date: Wed, 27 Jun 2007 19:22:38 -0400
Message-ID: <1182986558.5311.70.camel@heimdal.trondhjem.org>
References: <20070623153345.GA22117@ligo.caltech.edu>
	<1182615064.5859.2.camel@heimdal.trondhjem.org>
	<20070623215131.GC27551@ligo.caltech.edu>
	<20070627230453.GA14474@ligo.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: MalteSch@gmx.de, nfs@lists.sourceforge.net
To: Stuart Anderson <anderson@ligo.caltech.edu>,
	"Dr. J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I3gqc-0008JR-Hu
	for nfs@lists.sourceforge.net; Wed, 27 Jun 2007 16:22:54 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX191RETGfevhRm1CVd7TvzHy0jg3VLw+P4A=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I3gqd-0002Vx-R0
	for nfs@lists.sourceforge.net; Wed, 27 Jun 2007 16:22:58 -0700
In-Reply-To: <20070627230453.GA14474@ligo.caltech.edu>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Wed, 2007-06-27 at 16:04 -0700, Stuart Anderson wrote:
> This has patch has now been stable for 5 days on two different machines.
> 
> Any thoughts about the "bad sequence-id error"?

I seem to remember that a couple of sources of state corruption were
found in the server in and around the 2.6.20 series. Do I remember
correctly, Bruce?

Cheers
  Trond

> Thanks.
> 
> On Sat, Jun 23, 2007 at 02:51:31PM -0700, Stuart Anderson wrote:
> > Trond,
> > 
> > This applied cleanly to 2.6.20.14 and so far so good with 2.5hr uptime
> > on each of two machines that both previously had this Oops on an interval
> > of minutes up to 24hr. The statistics are not conclusive yet, but it does
> > boot and I was able to successfully run "make -j 8 boostrap" on the gcc
> > source code using 8 out of 16 CPU-cores on an NFSV4 mount without crashing.
> > 
> > However, the gcc build did generate 19 of the following on this client machine:
> > NFS: v4 server returned a bad sequence-id error!
> > Are these serious? How to go about tracking these down?
> > 
> > The server is a Sun X4500 running ZFS on Solaris10 Update 3 and it did
> > not log any error messages during the gcc build.
> > 
> > Very many thanks for incredible turn around a kernel patch--less than 40
> > minutes from Oops posting to patch posting!
> > 
> > 
> > Malte,
> > 	I suggest you give this patch a try as well to see if it solves your
> > similar/identical(?) Oops posted on lkml.
> > 
> > 
> > On Sat, Jun 23, 2007 at 12:11:04PM -0400, Trond Myklebust wrote:
> > > Does the attached patch (against 2.6.22) fix it?
> > > 
> > > Trond
> > > 
> > > 
> > > On Sat, 2007-06-23 at 08:33 -0700, Stuart Anderson wrote:
> > > > We started receiving frequent kernel (2.6.20.11) Oops messages in
> > > > nfs:nfs_update_inode on a pair of Sun X4600M2 machines once we started
> > > > mounting an NFS V4 filesystem from a Solaris x86 ZFS server.
> > > > 
> > > > Any help in tracking this down would be greatly appreciated.
> > > > 
> > > > Thanks.
> > > > 
> > > > Jun 22 18:15:49 ldas-grid kernel: Unable to handle kernel NULL pointer dereference at 0000000000000020 RIP: 
> > > > Jun 22 18:15:49 ldas-grid kernel:  [<ffffffff88170989>] :nfs:nfs_update_inode+0x99/0x5a0
> > > > Jun 22 18:15:49 ldas-grid kernel: PGD 3edd83067 PUD 3edd8b067 PMD 0 
> > > > Jun 22 18:15:49 ldas-grid kernel: Oops: 0000 [1] SMP 
> > > > Jun 22 18:15:49 ldas-grid kernel: CPU 7 
> > > > Jun 22 18:15:49 ldas-grid kernel: Modules linked in: nfsd exportfs autofs4 eeprom adm1026 hwmon_vid hwmon i2c_isa i2c_amd756
> > > >  i2c_amd8111 nfs lockd nfs_acl sunrpc ipt_REJECT xt_state usb_storage ip_conntrack nfnetlink xt_tcpudp iptable_filter ip_tab
> > > > les x_tables usbhid dm_mod ohci_hcd ehci_hcd i2c_nforce2 i2c_core e1000 usbcore mptsas scsi_transport_sas mptscsih mptbase s
> > > > d_mod scsi_mod
> > > > Jun 22 18:15:49 ldas-grid kernel: Pid: 33, comm: events/7 Not tainted 2.6.20.11-CIT #1
> > > > Jun 22 18:15:49 ldas-grid kernel: RIP: 0010:[<ffffffff88170989>]  [<ffffffff88170989>] :nfs:nfs_update_inode+0x99/0x5a0
> > > > Jun 22 18:15:49 ldas-grid kernel: RSP: 0018:ffff8103fbc3dc10  EFLAGS: 00010246
> > > > Jun 22 18:15:49 ldas-grid kernel: RAX: 0000000000000000 RBX: ffff81035d704ce8 RCX: 0000000000008180
> > > > Jun 22 18:15:49 ldas-grid kernel: RDX: ffff8101003cf8c0 RSI: ffff8103ace9c8d0 RDI: ffff81035d704ce8
> > > > Jun 22 18:15:49 ldas-grid kernel: RBP: ffff8103ace9c8d0 R08: 0000000000008180 R09: ffff8103eddf0030
> > > > Jun 22 18:15:49 ldas-grid kernel: R10: 0000000000000026 R11: 0000000000000003 R12: ffff81035d704b10
> > > > Jun 22 18:15:49 ldas-grid kernel: R13: ffff81035d704ce8 R14: ffff8101fbc3e6c0 R15: ffff8103ace9c8d0
> > > > Jun 22 18:15:49 ldas-grid kernel: FS:  00002b526bf797a0(0000) GS:ffff810300141d40(0000) knlGS:00000000f7dbb6c0
> > > > Jun 22 18:15:49 ldas-grid kernel: CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
> > > > Jun 22 18:15:49 ldas-grid kernel: CR2: 0000000000000020 CR3: 00000003edd89000 CR4: 00000000000006e0
> > > > Jun 22 18:15:49 ldas-grid kernel: Process events/7 (pid: 33, threadinfo ffff8103fbc3c000, task ffff8102fbcb90c0)
> > > > Jun 22 18:15:49 ldas-grid kernel: Stack:  ffff81035d704ce8 ffff8103ace9c8d0 ffff81035d704da0 ffff81035d704ce8
> > > > Jun 22 18:15:49 ldas-grid kernel:  ffff8101fbc3e6c0 ffffffff88170edb 0000000000000000 ffff8103ace9c800
> > > > Jun 22 18:15:49 ldas-grid kernel:  ffff810322664c00 ffffffff881817f0 ffff810376445de0 ffff8101003cf8c0
> > > > Jun 22 18:15:49 ldas-grid kernel: Call Trace:
> > > > Jun 22 18:15:49 ldas-grid kernel:  [<ffffffff88170edb>] :nfs:nfs_post_op_update_inode+0x4b/0x70
> > > > Jun 22 18:15:49 ldas-grid kernel:  [<ffffffff881817f0>] :nfs:nfs4_proc_delegreturn+0x160/0x1e0
> > > > Jun 22 18:15:49 ldas-grid kernel:  [<ffffffff8818e2ae>] :nfs:nfs_do_return_delegation+0x1e/0x40
> > > > Jun 22 18:15:50 ldas-grid kernel:  [<ffffffff8816d0e3>] :nfs:nfs_dentry_iput+0x23/0x70
> > > > Jun 22 18:15:50 ldas-grid kernel:  [<ffffffff802999a2>] shrink_dcache_for_umount_subtree+0x212/0x270
> > > > Jun 22 18:15:50 ldas-grid kernel:  [<ffffffff80299a53>] shrink_dcache_for_umount+0x53/0x70
> > > > Jun 22 18:15:50 ldas-grid kernel:  [<ffffffff80288ce9>] generic_shutdown_super+0x19/0x100
> > > > Jun 22 18:15:50 ldas-grid kernel:  [<ffffffff80288e29>] kill_anon_super+0x9/0x40
> > > > Jun 22 18:15:50 ldas-grid kernel:  [<ffffffff881724ad>] :nfs:nfs_kill_super+0xd/0x20
> > > > Jun 22 18:15:50 ldas-grid kernel:  [<ffffffff80289046>] deactivate_super+0x76/0xb0
> > > > Jun 22 18:15:50 ldas-grid kernel:  [<ffffffff802a1573>] expire_mount_list+0x133/0x180
> > > > Jun 22 18:15:50 ldas-grid kernel:  [<ffffffff8817a7a0>] :nfs:nfs_expire_automounts+0x0/0x40
> > > > Jun 22 18:15:50 ldas-grid kernel:  [<ffffffff802a176b>] mark_mounts_for_expiry+0xab/0xc0
> > > > Jun 22 18:15:50 ldas-grid kernel:  [<ffffffff8817a7b0>] :nfs:nfs_expire_automounts+0x10/0x40
> > > > Jun 22 18:15:50 ldas-grid kernel:  [<ffffffff8023fd6e>] run_workqueue+0xae/0x160
> > > > Jun 22 18:15:50 ldas-grid kernel:  [<ffffffff8023fee0>] worker_thread+0x0/0x190
> > > > Jun 22 18:15:50 ldas-grid kernel:  [<ffffffff80240031>] worker_thread+0x151/0x190
> > > > Jun 22 18:15:50 ldas-grid kernel:  [<ffffffff80229490>] default_wake_function+0x0/0x10
> > > > Jun 22 18:15:50 ldas-grid kernel:  [<ffffffff8023fee0>] worker_thread+0x0/0x190
> > > > Jun 22 18:15:50 ldas-grid kernel:  [<ffffffff80243b79>] kthread+0xd9/0x120
> > > > Jun 22 18:15:50 ldas-grid kernel:  [<ffffffff802298cc>] schedule_tail+0x4c/0xb0
> > > > Jun 22 18:15:50 ldas-grid kernel:  [<ffffffff8020a998>] child_rip+0xa/0x12
> > > > Jun 22 18:15:50 ldas-grid kernel:  [<ffffffff80219250>] flat_send_IPI_mask+0x0/0x60
> > > > Jun 22 18:15:50 ldas-grid kernel:  [<ffffffff80243aa0>] kthread+0x0/0x120
> > > > Jun 22 18:15:50 ldas-grid kernel:  [<ffffffff8020a98e>] child_rip+0x0/0x12
> > > > Jun 22 18:15:50 ldas-grid kernel: 
> > > > Jun 22 18:15:50 ldas-grid kernel: 
> > > > Jun 22 18:15:50 ldas-grid kernel: Code: 48 3b 58 20 75 31 48 8b 45 60 48 39 82 b0 00 00 00 48 8d 75 
> > > > Jun 22 18:15:50 ldas-grid kernel: RIP  [<ffffffff88170989>] :nfs:nfs_update_inode+0x99/0x5a0
> > > > Jun 22 18:15:50 ldas-grid kernel:  RSP <ffff8103fbc3dc10>
> > > > Jun 22 18:15:50 ldas-grid kernel: CR2: 0000000000000020
> > > > 
> > 
> > > From: Trond Myklebust <Trond.Myklebust@netapp.com>
> > > Date: Tue, 5 Jun 2007 13:26:15 -0400
> > > NFS: Fix nfs_reval_fsid()
> > > Subject: No Subject
> > > 
> > > We don't need to revalidate the fsid on the root directory. It suffices to
> > > revalidate it on the current directory.
> > > 
> > > Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> > > ---
> > > 
> > >  fs/nfs/dir.c   |    9 ++++-----
> > >  fs/nfs/inode.c |    4 ++--
> > >  2 files changed, 6 insertions(+), 7 deletions(-)
> > > 
> > > diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> > > index 4948ec1..c02a796 100644
> > > --- a/fs/nfs/dir.c
> > > +++ b/fs/nfs/dir.c
> > > @@ -897,14 +897,13 @@ int nfs_is_exclusive_create(struct inode *dir, struct nameidata *nd)
> > >  	return (nd->intent.open.flags & O_EXCL) != 0;
> > >  }
> > >  
> > > -static inline int nfs_reval_fsid(struct vfsmount *mnt, struct inode *dir,
> > > -				 struct nfs_fh *fh, struct nfs_fattr *fattr)
> > > +static inline int nfs_reval_fsid(struct inode *dir, const struct nfs_fattr *fattr)
> > >  {
> > >  	struct nfs_server *server = NFS_SERVER(dir);
> > >  
> > >  	if (!nfs_fsid_equal(&server->fsid, &fattr->fsid))
> > > -		/* Revalidate fsid on root dir */
> > > -		return __nfs_revalidate_inode(server, mnt->mnt_root->d_inode);
> > > +		/* Revalidate fsid using the parent directory */
> > > +		return __nfs_revalidate_inode(server, dir);
> > >  	return 0;
> > >  }
> > >  
> > > @@ -946,7 +945,7 @@ static struct dentry *nfs_lookup(struct inode *dir, struct dentry * dentry, stru
> > >  		res = ERR_PTR(error);
> > >  		goto out_unlock;
> > >  	}
> > > -	error = nfs_reval_fsid(nd->mnt, dir, &fhandle, &fattr);
> > > +	error = nfs_reval_fsid(dir, &fattr);
> > >  	if (error < 0) {
> > >  		res = ERR_PTR(error);
> > >  		goto out_unlock;
> > > diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> > > index 23ecf03..7bcb3df 100644
> > > --- a/fs/nfs/inode.c
> > > +++ b/fs/nfs/inode.c
> > > @@ -961,8 +961,8 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
> > >  		goto out_changed;
> > >  
> > >  	server = NFS_SERVER(inode);
> > > -	/* Update the fsid if and only if this is the root directory */
> > > -	if (inode == inode->i_sb->s_root->d_inode
> > > +	/* Update the fsid? */
> > > +	if (S_ISDIR(inode->i_mode)
> > >  			&& !nfs_fsid_equal(&server->fsid, &fattr->fsid))
> > >  		server->fsid = fattr->fsid;
> > >  
> > 
> > 
> > -- 
> > Stuart Anderson  anderson@ligo.caltech.edu
> > http://www.ligo.caltech.edu/~anderson
> 


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
