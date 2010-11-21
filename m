Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:57556 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754464Ab0KUWl4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 21 Nov 2010 17:41:56 -0500
Date: Sun, 21 Nov 2010 17:41:54 -0500
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Hiroyuki Sato <hiroysato@gmail.com>, linux-nfs@vger.kernel.org,
        linux-rdma@vger.kernel.org
Subject: Re: [Q] I tried to mount nfs_server:/mnt volume, but It mounted
 another volume.
Message-ID: <20101121224154.GA11043@fieldses.org>
References: <AANLkTi=vpRm3MEiQZ39bw5XwfjL6CVbGEkAKWz-ynEp_@mail.gmail.com>
 <4CE9217E.6090002@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4CE9217E.6090002@panasas.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, Nov 21, 2010 at 03:41:18PM +0200, Boaz Harrosh wrote:
> On 11/21/2010 02:23 PM, Hiroyuki Sato wrote:
> > Hello lists
> > 
> > OS: CentOS 5.5
> > kernel: 2.6.36 rebuild myself.
> > 
> > 
> >   I'm trying to test NFS/RDMA.
> >   I tried to mount nfs_server:/mnt volume on on nfs_client
> >   but It mounted nfs_server:/nfstest volume
> > 
> >   note: /nfstest is tmpfs
> > 
> >  this is mount output
> >     tmpfs on /nfstest type tmpfs (rw,size=4g)
> >     /dev/sdb1 on /mnt type ext3 (rw)
> > 
> >   Is this bug??
> > 
> > NFS server config
> > 
> >   # ls -1 /mnt
> >   This_is_mnt_volume
> > 
> >   # ls -1 /nfstest
> >   This_is_nfstest_volume
> > 
> >   # cat /etc/exports
> >   /nfstest   192.168.100.0/255.255.255.0(fsid=0,rw,async,insecure,no_root_squash)
> >   /mnt       192.168.100.0/255.255.255.0(fsid=0,rw,async,insecure,no_root_squash)
> > 
> 
> You must not have two exports with fsid=0. First one is picked. 
> 
> nfs4 will only export a single name space point, other exports are
> subdirs of that root export. (use bind mounts to present a single
> directory tree)
> 
> <http://www.citi.umich.edu/projects/nfsv4/linux/using-nfsv4.html>

We should update and/or replace that documentation; with new nfs-utils
and kernel, if you omit the "fsid=0", you'll end up with an nfsv4
namespace that's the same as v2/v3's always was.

--b.

> 
> NFSv4 exports on linux
> ~~~~~~~~~~~~~~~~~~~~~~
> 
> NFSv4 no longer has a separate "mount" protocol. Instead of exporting a number of distinct exports, an NFSv4 client sees the NFSv4 server's exports as existing inside a single filesystem, called the nfsv4 "pseudofilesystem".
> 
> On the current linux implementation, the pseudofilesystem is a single real filesystem, identified at export with the fsid=0 option.
> 
> In the example above, we exported only a single filesystem, which the client mounted as "/". You can provide clients with multiple filesystems to mount, producing NFSv3-like-behavior, by creative use of mount --bind. For example, you could export /usr/local/bin to clients as /bin and /usr/local/etc as /etc as follows:
> 
> mkdir /export
> mkdir /export/bin
> mkdir /export/etc
> mount --bind /usr/local/bin /export/bin
> mount --bind /usr/local/etc /export/etc
> exportfs -ofsid=0,insecure,no_subtree_check *:/export
> exportfs -orw,nohide,insecure,no_subtree_check *:/export/bin
> exportfs -orw,nohide,insecure,no_subtree_check *:/export/etc
> 
> Note that the paths returned by the "showmount" program are meaningful only to clients using nfs versions 2 and 3; in the above example, "showmount" will list the paths /export, /export/bin/, and /export/etc, but nfsv4 clients should mount yourserver:/, yourserver:/bin, or yourserver:/etc.
> 
> </http://www.citi.umich.edu/projects/nfsv4/linux/using-nfsv4.html>
> 
> Boaz
> > 
> >   # modprobe svcrdma
> > 
> >   # /sbin/service nfs start
> > 
> >   # echo rdma 20049 > /proc/fs/nfsd/portlist
> > 
> > 
> > Client Setting
> > 
> >   /sbin/modprobe xprtrdma
> >   /sbin/mount.rnfs 192.168.100.231:/mnt /mnt -i -o rdma,port=20049
> > 
> >   # ls -1 /mnt
> >   This_is_nfstest_volume
> > 
> > NFS Server log
> >   sysctl -w sunrpc.nfsd_debug=1023
> > 
> >   Nov 21 20:47:37 dell1435 mountd[3575]: authenticated mount request
> > from 192.168.100.232:766 for /mnt (/mnt)
> >   Nov 21 20:47:37 dell1435 mountd[3575]: /nfstest and /mnt have same
> > filehandle for 192.168.100.0/255.255.255.0, using first
> >   Nov 21 20:48:55 dell1435 mountd[3575]: authenticated unmount request
> > from 192.168.100.232:912 for /mnt (/mnt)
> >   Nov 21 20:48:55 dell1435 mountd[3575]: authenticated unmount request
> > from 192.168.100.232:913 for /mnt (/mnt)
> >   Nov 21 20:49:00 dell1435 mountd[3575]: authenticated unmount request
> > from 192.168.100.232:917 for /mnt (/mnt)
> >   Nov 21 20:49:16 dell1435 mountd[3575]: authenticated mount request
> > from 192.168.100.232:865 for /mnt (/mnt)
> >   Nov 21 21:02:22 dell1435 mountd[3575]: authenticated unmount request
> > from 192.168.100.232:955 for /mnt (/mnt)
> >   Nov 21 21:02:26 dell1435 mountd[3575]: authenticated mount request
> > from 192.168.100.232:884 for /mnt (/mnt)
> >   Nov 21 21:02:26 dell1435 kernel: nfsd: exp_rootfh(/mnt
> > [ffff88011f586740] 192.168.100.0/255.255.255.0:sdb1/2)
> > 
> > 
> > --
> > Hiroyuki Sato
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
