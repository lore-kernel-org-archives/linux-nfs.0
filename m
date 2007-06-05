From: Marc Eshel <eshel@almaden.ibm.com>
Subject: Re: [NFS] [PATCH] locks: provide a file lease method enabling	cluster-coherent
 leases
Date: Tue, 5 Jun 2007 15:56:54 -0700
Message-ID: <OFB9D089FA.C0E6BE5A-ON882572F1.007D3720-882572F1.007E299C@us.ibm.com>
References: <f0a71180706051504j712f7415vc82682e0958a2239@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net,
	David Teigland <teigland@redhat.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: "Robert Rappaport" <robert.rappaport@gmail.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <f0a71180706051504j712f7415vc82682e0958a2239@mail.gmail.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Hi Bruce,
The file system does need to keep the local state up to date, like it does 
with posix locks, so it might need to call __setlease(). The why we had it 
before was that the call to the file system was done from outside of 
setlease() and the file system was able to call setlease() which is 
exported. Now that the call to the fs  moved into setlease() the file 
system can not call it anymore so one possible solution would be to export 
__setlease().
Marc.

nfs-bounces@lists.sourceforge.net wrote on 06/05/2007 03:04:57 PM:

> I have had some previous communications with Bruce on these topics, 
> and I am generally pleased with the proposed modifications that are 
> presented here.
> 
> I am working on a clustered file system and there is one small 
> additional modification that would be of great use to me.  That 
> would be to export the __setlease symbol.
> 
> In my implementation, my file system specific set_lease() function 
> first determines whether the granting of the requested lease on the 
> given inode is compatible with the cluster state of this inode, and 
> then if it is, I simply invoke the __setlease() routine and have the
> kernel build the associated infrastructure.
> 
> Having this symbol globally available greatly simplifies things.

> On 6/4/07, J. Bruce Fields <bfields@fieldses.org > wrote:
> On Sat, Jun 02, 2007 at 02:21:22PM -0400, Trond Myklebust wrote:
> > Currently, the lease handling is done all in the VFS, and is done 
prior 
> > to calling any filesystem operations. Bruce's break_lease() inode
> > operation allows the VFS to notify the filesystem that some operation 
is
> > going to be called that requires the lease to be broken. 
> >
> > My point is that in doing so, you are not atomic with the operation 
that
> > requires the lease to be broken. Some different node may re-establish 
a
> > lease while we're calling back down into the filesystem to perform the 

> > operation.
> > So I agree with you. The break_lease() inode operation isn't going to
> > work. The filesystem is going to have to figure out for itself when it
> > needs to notify other nodes that the lease needs breaking, and it 
needs 
> > to figure out its own methods for ensuring atomicity.
> 
> OK, I agree with you both, thanks for the explanations.
> 
> It looks to me like there's probably a race in the existing code that
> will allow conflicting opens and leases to be granted simultaneously if 
> the lease request is handled just after may_open() is called.  These
> checks at the beginning of __setlease() are an attempt to prevent that
> race:
> 
>         if ((arg == F_RDLCK) && (atomic_read(&inode->i_writecount) > 0)) 

>                 goto out;
>         if ((arg == F_WRLCK)
>             && ((atomic_read(&dentry->d_count) > 1)
>                 || (atomic_read(&inode->i_count) > 1)))
>                 goto out;
> 
> But, for example, in the case of a simultaneous write open and RDLCK
> lease request, I believe the call to setlease could come after the 
> may_open() but before the call to get_write_access() that bumps
> i_writecount.
> 
> --b.
> -
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" 
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
-------------------------------------------------------------------------
> This SF.net email is sponsored by DB2 Express
> Download DB2 Express C - the FREE version of DB2 express and take
> control of your XML. No limits. Just data. Click to get it now.
> http://sourceforge.net/powerbar/db2/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

