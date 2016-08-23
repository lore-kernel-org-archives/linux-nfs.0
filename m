Return-Path: <trondmy@primarydata.com>
From: Trond Myklebust <trondmy@primarydata.com>
To: Coddington Benjamin <bcodding@redhat.com>
CC: List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Subject: Re: I can't get no readdir satisfaction
Date: Tue, 23 Aug 2016 15:36:40 +0000
Message-ID: <F9D0E173-9E64-4BC4-87FB-0F6F4EEBF4C7@primarydata.com>
References: <778246F3-8F24-48FD-AEA9-0BCC0DCD93B3@redhat.com>
In-Reply-To: <778246F3-8F24-48FD-AEA9-0BCC0DCD93B3@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
List-ID: <linux-nfs.vger.kernel.org>


> On Aug 23, 2016, at 11:09, Benjamin Coddington <bcodding@redhat.com> wrot=
e:
>=20
> Hi linux-nfs,
>=20
> 311324ad1713 ("NFS: Be more aggressive in using readdirplus for 'ls -l'
> situations") changed when nfs_readdir() decides to revalidate the
> directory's mapping, which contains all the entries.  In addition to just
> checking if the attribute cache has expired, it includes a check to see i=
f
> NFS_INO_INVALID_DATA is set on the directory.
>=20
> Well, customers that have directories with very many dentries and that sa=
me
> directory's attributes are frequently updated are now grouchy that `ls -l=
`
> takes so long since any update of the directory causes the mapping to be
> invalidated and we have to start over filling the directory's mapping.
>=20
> I actually haven't put real hard thought into it yet (because often for m=
e
> that just wastes a lot of time), so I am doing the lazy thing by asking t=
his
> question:
>=20
> Can we go back to just the using the attribute cache timeout, or should w=
e
> get all heuristical about readdir?
>=20

We are all heuristical at this point. How are the heuristics failing?

The original problem those heuristics were designed to solve was that all t=
he stat() calls took forever to complete, since they are all synchronous; T=
igran showed some very convincing numbers for a large directory where the d=
ifference in performance was an order of magnitude improved by using readdi=
rplus instead of readdir=85
