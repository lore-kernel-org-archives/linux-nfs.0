Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:50874 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727381AbeHJTbH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 10 Aug 2018 15:31:07 -0400
Date: Fri, 10 Aug 2018 13:00:27 -0400
From: Bruce Fields <bfields@fieldses.org>
To: NeilBrown <neilb@suse.com>
Cc: Nelson Elhage <nelhage@nelhage.com>,
        Christoph Hellwig <hch@lst.de>, linux-nfs@vger.kernel.org,
        James Brown <jbrown@easypost.com>
Subject: Re: NFSv3 may inappropriately return EPERM for fsetxattr
Message-ID: <20180810170027.GF7906@fieldses.org>
References: <CAPSG9dbOPRv_gM_w_Ys9fJ-fSPRnw+Rgb3yaaHVEqZ9YyDntzg@mail.gmail.com>
 <20160321144349.GA12804@lst.de>
 <CAPSG9dZX45Uq07Xue55Aom3i-WyH9_SA_SKydBjsEX1Y14VwoA@mail.gmail.com>
 <874lg3roua.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <874lg3roua.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 10, 2018 at 11:29:33AM +1000, NeilBrown wrote:
> On Mon, Mar 21 2016, Nelson Elhage wrote:
> 
> > That's correct. The other detail that seems to be important is that
> > the user making the call must be different from the user owning the
> > file. We've also been using user remapping on the server, so that
> > non-xattr calls succeed in that configuration.
> >
> > The reproducer James added in the bugzilla is:
> >
> > (on machine with IP address 10.1.1.1)
> > sudo mkdir /nfs_test
> > sudo useradd -u 10000 test_user
> > sudo chown test_user /nfs_test
> > echo "/nfs_test 10.1.1.2(rw,all_squash,anonuid=10000)" | sudo tee -a
> > /etc/exports
> > sudo exportfs -a
> >
> > (on machine with IP address 10.1.1.2)
> > sudo mkdir /nfs_test
> > sudo mount -t nfs -o vers=3,noacl 10.1.1.1:/nfs_test /nfs_test
> > touch /nfs_test/foo
> > install -m 755 /nfs_test/foo /nfs_test/bar
> 
> Did anything ever happen about this?
> I have a customer with a similar problem (in 4.4) but I cannot see any
> evidence of fixes landing in mainline.
> 
> Problem happens with you have uid mapping on the server
> (e.g. anonuid=10000 as above) and a user with a different uid on the
> client attempts setacl on a file with that user.
> As anon is mapped to the owner of the file, setacl should be allowed.
> However set_posix_acl() calls inode_owner_or_capable() which checks if
> the client-side uid matches the visible inode->i_uid - they don't.
> 
> Testing i_uid on the client is always incorrect for permission checking
> with NFS - the client should always ask the server, either with ACCESS
> or, in this case, by simply attempting the operation.
> 
> Any suggestions how best to fix this?
> - We could move the responsibility for permission checking into
>   i_op->set_acl, but that would be a large change and might make it too
>   easy for other filesystems to get it wrong.
> - we could have some sort of flag asking set_posix_acl(), but that's
>   rather clumsy.... maybe if i_op->set_acl_check_perm use that without
>   testing ownership first??
> - we could copy
>     posic_acl_xattr_{get,set,list} into nfs together with functions
>     they call, modify set_posix_acl() to not test ownership,
>     and provide a local 'struct xattr_handler' structure for NFS.
> 
> I don't really like any of those suggestions.  Can someone else do any
> better?

Do we have important callers of inode_owner_or_capable() in the vfs (as
opposed to in individual filesystems), and do any of them pose a similar
problem for network filesystems?

--b.
