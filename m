Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:43140 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965434AbaFQVUN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Jun 2014 17:20:13 -0400
Date: Tue, 17 Jun 2014 17:04:39 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC] nfs: ensure cached data is correct before using
 delegation
Message-ID: <20140617210439.GC4510@tonberry.usersys.redhat.com>
References: <1402683488-23725-1-git-send-email-smayhew@redhat.com>
 <1402683488-23725-2-git-send-email-smayhew@redhat.com>
 <CAABAsM5kJFJK_-VwL4bB4ZUvpdx4pFEYqXKN1S7KqdF6=Xc76g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAABAsM5kJFJK_-VwL4bB4ZUvpdx4pFEYqXKN1S7KqdF6=Xc76g@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

On Fri, 13 Jun 2014, Trond Myklebust wrote:

> On Fri, Jun 13, 2014 at 2:18 PM, Scott Mayhew <smayhew@redhat.com> wrote:
> > nfs_write_pageuptodate()  bypasses the cache_validity flags whenever we
> > have a delegation... but in order to do that we need to be sure our
> > cached data is correct to begin with.
> > ---
> >  fs/nfs/delegation.c | 1 +
> >  fs/nfs/inode.c      | 1 +
> >  fs/nfs/nfs4proc.c   | 5 +++--
> >  3 files changed, 5 insertions(+), 2 deletions(-)
> >
> > diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
> > index 5d8ccec..12f3eca 100644
> > --- a/fs/nfs/delegation.c
> > +++ b/fs/nfs/delegation.c
> > @@ -167,6 +167,7 @@ void nfs_inode_reclaim_delegation(struct inode *inode, struct rpc_cred *cred,
> >                         spin_unlock(&delegation->lock);
> >                         rcu_read_unlock();
> >                         nfs_inode_set_delegation(inode, cred, res);
> > +                       nfs_revalidate_mapping(inode, inode->i_mapping);
> 
> If you are reclaiming a delegation after a server reboot, then nobody
> is supposed to have changed the file.

Agreed.
> 
> >                 }
> >         } else {
> >                 rcu_read_unlock();
> > diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> > index c496f8a..95a9d21 100644
> > --- a/fs/nfs/inode.c
> > +++ b/fs/nfs/inode.c
> > @@ -1090,6 +1090,7 @@ int nfs_revalidate_mapping(struct inode *inode, struct address_space *mapping)
> >  out:
> >         return ret;
> >  }
> > +EXPORT_SYMBOL_GPL(nfs_revalidate_mapping);
> >
> >  static unsigned long nfs_wcc_update_inode(struct inode *inode, struct nfs_fattr *fattr)
> >  {
> > diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> > index 285ad53..a538aac 100644
> > --- a/fs/nfs/nfs4proc.c
> > +++ b/fs/nfs/nfs4proc.c
> > @@ -1361,11 +1361,12 @@ nfs4_opendata_check_deleg(struct nfs4_opendata *data, struct nfs4_state *state)
> >                                    "returning a delegation for "
> >                                    "OPEN(CLAIM_DELEGATE_CUR)\n",
> >                                    clp->cl_hostname);
> > -       } else if ((delegation_flags & 1UL<<NFS_DELEGATION_NEED_RECLAIM) == 0)
> > +       } else if ((delegation_flags & 1UL<<NFS_DELEGATION_NEED_RECLAIM) == 0) {
> >                 nfs_inode_set_delegation(state->inode,
> >                                          data->owner->so_cred,
> >                                          &data->o_res);
> > -       else
> > +               nfs_revalidate_mapping(state->inode, state->inode->i_mapping);
> > +       } else
> >                 nfs_inode_reclaim_delegation(state->inode,
> >                                              data->owner->so_cred,
> >                                              &data->o_res);
> 
> I'd really prefer to fix this in the part of the code that is actually broken.
> 
> I agree that we should ignore the NFS_INO_REVAL_PAGECACHE flag if we
> have a delegation and the NFS_INO_REVAL_FORCED is unset. However is it
> right to ignore NFS_INO_INVALID_DATA?
> 

No, I don't think it's right to ignore NFS_INO_INVALID_DATA, and
originally I was testing a fix similar to this:

---8<---
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 3ee5af4..98ff061 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -934,12 +934,14 @@ static bool nfs_write_pageuptodate(struct page *page, struct inode *inode)
 
        if (nfs_have_delegated_attributes(inode))
                goto out;
-       if (nfsi->cache_validity & (NFS_INO_INVALID_DATA|NFS_INO_REVAL_PAGECACHE))
+       if (nfsi->cache_validity & NFS_INO_REVAL_PAGECACHE)
                return false;
        smp_rmb();
        if (test_bit(NFS_INO_INVALIDATING, &nfsi->flags))
                return false;
 out:
+       if (nfsi->cache_validity & NFS_INO_INVALID_DATA)
+               return false;
        return PageUptodate(page) != 0;
 }
---8<---


However,

1) it wasn't really keeping with the spirit of commit 8d197a56 (NFS:
Always trust the PageUptodate flag when we have a delegation), and

2) one of my test programs (used to test commit c7559663 (NFS: Allow
nfs_updatepage to extend a write under additional circumstances)))
started performing poorly again, doing tons of sub page-sized writes
intead of a handful of wsize'd writes.

I did some more digging and I think I see 2 areas that could be
improved. 

The first would be to clear NFS_INO_INVALID_DATA if we've just
truncated the inode to 0 bytes -- after all, if we've just unmapped
all the pages from the inode's address space then isn't our data
consisitent?:

---8<---
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index c496f8a..1078d06 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -584,6 +584,11 @@ void nfs_setattr_update_inode(struct inode *inode, struct iattr *attr)
        if ((attr->ia_valid & ATTR_SIZE) != 0) {
                nfs_inc_stats(inode, NFSIOS_SETATTRTRUNC);
                nfs_vmtruncate(inode, attr->ia_size);
+               if (attr->ia_size == 0) {
+                       spin_lock(&inode->i_lock);
+                       NFS_I(inode)->cache_validity &= ~NFS_INO_INVALID_DATA;
+                       spin_unlock(&inode->i_lock);
+               }
        }
 }
 EXPORT_SYMBOL_GPL(nfs_setattr_update_inode);
---8<---


The second thing I noticed is that we're constantly invalidating our
cache due to the change attribute changing on the server.  But if we
have a write delegation then the change attribute changing must be the
result of *our* changes, in which case we should be able to just silently
update the change attribute on our side without invalidating our caches:

---8<---
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 1078d06..932c999 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1568,15 +1568,17 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
        /* More cache consistency checks */
        if (fattr->valid & NFS_ATTR_FATTR_CHANGE) {
                if (inode->i_version != fattr->change_attr) {
-                       dprintk("NFS: change_attr change on server for file %s/%ld\n",
+                       if (!NFS_PROTO(inode)->have_delegation(inode, FMODE_WRITE)) { 
+                               dprintk("NFS: change_attr change on server for file %s/%ld\n",
                                        inode->i_sb->s_id, inode->i_ino);
-                       invalid |= NFS_INO_INVALID_ATTR
-                               | NFS_INO_INVALID_DATA
-                               | NFS_INO_INVALID_ACCESS
-                               | NFS_INO_INVALID_ACL
-                               | NFS_INO_REVAL_PAGECACHE;
-                       if (S_ISDIR(inode->i_mode))
-                               nfs_force_lookup_revalidate(inode);
+                               invalid |= NFS_INO_INVALID_ATTR
+                                       | NFS_INO_INVALID_DATA
+                                       | NFS_INO_INVALID_ACCESS
+                                       | NFS_INO_INVALID_ACL
+                                       | NFS_INO_REVAL_PAGECACHE;
+                               if (S_ISDIR(inode->i_mode))
+                                       nfs_force_lookup_revalidate(inode);
+                       }
                        inode->i_version = fattr->change_attr;
                }
        } else if (server->caps & NFS_CAP_CHANGE_ATTR)
---8<---

If you think these 3 changes look alright then I'll do some more testing
and then send the patches (but I'd rather not spend too much time
testing if you see an issue with the changes in the first place).

Thanks,
Scott
