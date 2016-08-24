Return-Path: <bfields@fieldses.org>
Date: Wed, 24 Aug 2016 09:56:03 -0400
To: Trond Myklebust <trondmy@primarydata.com>
Cc: Coddington Benjamin <bcodding@redhat.com>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Subject: Re: I can't get no readdir satisfaction
Message-ID: <20160824135603.GF3938@fieldses.org>
References: <778246F3-8F24-48FD-AEA9-0BCC0DCD93B3@redhat.com>
 <F9D0E173-9E64-4BC4-87FB-0F6F4EEBF4C7@primarydata.com>
 <98E39192-4203-4EB8-BDE0-2A4ABFCAA92B@redhat.com>
 <81D2E080-0697-4B26-BE38-5E8AC35C2EA4@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <81D2E080-0697-4B26-BE38-5E8AC35C2EA4@primarydata.com>
From: bfields@fieldses.org (J. Bruce Fields)
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 24, 2016 at 12:18:04PM +0000, Trond Myklebust wrote:
>=20
> > On Aug 23, 2016, at 17:21, Benjamin Coddington <bcodding@redhat.com> wr=
ote:
> >=20
> >=20
> >=20
> > On 23 Aug 2016, at 11:36, Trond Myklebust wrote:
> >=20
> >>> On Aug 23, 2016, at 11:09, Benjamin Coddington <bcodding@redhat.com> =
wrote:
> >>>=20
> >>> Hi linux-nfs,
> >>>=20
> >>> 311324ad1713 ("NFS: Be more aggressive in using readdirplus for 'ls -=
l'
> >>> situations") changed when nfs_readdir() decides to revalidate the
> >>> directory's mapping, which contains all the entries.  In addition to =
just
> >>> checking if the attribute cache has expired, it includes a check to s=
ee if
> >>> NFS_INO_INVALID_DATA is set on the directory.
> >>>=20
> >>> Well, customers that have directories with very many dentries and tha=
t same
> >>> directory's attributes are frequently updated are now grouchy that `l=
s -l`
> >>> takes so long since any update of the directory causes the mapping to=
 be
> >>> invalidated and we have to start over filling the directory's mapping.
> >>>=20
> >>> I actually haven't put real hard thought into it yet (because often f=
or me
> >>> that just wastes a lot of time), so I am doing the lazy thing by aski=
ng this
> >>> question:
> >>>=20
> >>> Can we go back to just the using the attribute cache timeout, or shou=
ld we
> >>> get all heuristical about readdir?
> >>>=20
> >>=20
> >> We are all heuristical at this point. How are the heuristics failing?
> >>=20
> >> The original problem those heuristics were designed to solve was that =
all
> >> the stat() calls took forever to complete, since they are all synchron=
ous;
> >> Tigran showed some very convincing numbers for a large directory where=
 the
> >> difference in performance was an order of magnitude improved by using
> >> readdirplus instead of readdir=E2=80=A6
> >=20
> > I'll try to present a better explanation.  While `ls -l` is walking thr=
ough
> > a directory repeatedly entering nfs_readdir(), a CREATE response send us
> > through nfs_post_op_update_inode_locked():
> >=20
> > 1531     if (S_ISDIR(inode->i_mode))
> > 1532         invalid |=3D NFS_INO_INVALID_DATA;
> > 1533     nfs_set_cache_invalid(inode, invalid);
> >=20
> > Now, the next entry into nfs_readdir() has us do nfs_revalidate_mapping=
(),
> > which will do nfs_invalidate_mapping() for the directory, and so we hav=
e to
> > start over with cookie 0 sending READDIRPLUS to re-fill the directory's
> > mapping to get back to where we are for the current nfs_readdir().
> >=20
> > This process repeats for every entry into nfs_readdir() if the directory
> > keeps getting updated, and it becomes more likely that it will be updat=
ed as
> > each pass takes longer and longer to re-fill the mapping as the current
> > nfs_readdir() invocation is further along.
> >=20
> > READDIRPLUS isn't the problem, the problem is invalidating the directory
> > mapping in the middle of a series of getdents() if we do a CREATE.  Als=
o, I
> > think a similar thing happens if the directory's mtime or ctime is upda=
ted -
> > but in that case we set NFS_INO_INVALID_DATA because the change_attr
> > updates.
> >=20
> > So, for directories with a large number of entries that updates often, =
it can
> > be very slow to list the directory.
> >=20
> > Why did 311324ad1713 change nfs_readdir from
> >=20
> > if (nfs_attribute_cache_expired(inode))
> >    nfs_revalidate_mapping(inode, file->f_mapping);
> > to
> >=20
> > if (nfs_attribute_cache_expired(inode) || nfsi->cache_validity & NFS_IN=
O_INVALID_DATA)
> >    nfs_revalidate_mapping(inode, file->f_mapping);
>=20
> As the commit message says, the whole purpose was to use READDIRPLUS as a=
 substitute for multiple GETATTR calls when the heuristic tells us that the=
 user is performing an =E2=80=98ls -l=E2=80=99 style of workload.
>=20
> >=20
> > .. and can we go back to the way it was before?
>=20
> Not without slowing down =E2=80=98ls -l=E2=80=99 on large directories.
>=20
> >=20
> > OK.. I understand why -- it is more correct since if we know the direct=
ory has
> > changed, we might as well fetch the change.  Otherwise, we might be cre=
ating
> > files and then wondering why they aren't listed.
> >=20
> > It might be nicer to not invalidate the mapping we're currently using f=
or
> > readdir, though.  Maybe there's a way to keep the mapping for the curre=
ntly
> > opened directory and invalidate it once it's closed.
>=20

>  POSIX requires that you revalidate on opendir() and rewinddir(), and
>  leaves behaviour w.r.t. file addition and removal after the call to
>  opendir()/rewinddir() undefined
>  (http://pubs.opengroup.org/onlinepubs/9699919799/functions/readdir.html).

It is only undefined whether the added or removed entry is returned.
Other entries still need to returned exactly once.

In this case we're restarting the read of the directory from scratch--I
don't understand how that's possible while avoiding skipped or
duplicated entries.

Surely the only safe thing to do is to continue reading using the last
cookie returned from the server.

--b.

>  I believe most filesystems under Linux will ensure that if a file is
>  removed, it is no longer seen in the readdir stream, and a file that
>  is added will be seen unless the readdir cursor has already passed
>  it, so there is that to consider.

>=20
> However correctness was not the main issue here.
>=20
> N?????r??y????b?X??=C7=A7v?^?)=DE=BA{.n?+????{???"??^n?r???z?=1A??h?????&=
??=1E?G???h?=03(?=E9=9A=8E?=DD=A2j"??=1A?=1Bm??????z?=DE=96???f???h???~?m
