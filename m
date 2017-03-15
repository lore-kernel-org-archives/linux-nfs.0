Return-Path: <chuck.lever@oracle.com>
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: git "make test" fails in t9200-git-cvsexportcommit.sh
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <EEDA8B03-DB54-47BA-A6FD-AF293BFEDE8E@redhat.com>
Date: Wed, 15 Mar 2017 14:30:15 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <E05A04E0-E9F5-465E-9E2A-EB89FC444FA7@oracle.com>
References: <12A85CA0-A715-4379-81D5-58A9CB001266@oracle.com> <5E4A3C66-5123-446D-9556-0E59E546283D@redhat.com> <EEDA8B03-DB54-47BA-A6FD-AF293BFEDE8E@redhat.com>
To: Benjamin Coddington <bcodding@redhat.com>
List-ID: <linux-nfs.vger.kernel.org>


> On Mar 15, 2017, at 10:00 AM, Benjamin Coddington =
<bcodding@redhat.com> wrote:
>=20
> On 14 Mar 2017, at 18:25, Benjamin Coddington wrote:
>=20
>> Hi Chuck,
>>=20
>> On 14 Mar 2017, at 11:07, Chuck Lever wrote:
>>=20
>>> Hi Ben!
>>>=20
>>> After addressing some IB stack issues that arose in v4.11-rc1,
>>> I was finally able to run my standard suite of NFS tests with
>>> v4.11-rc2. I found that part of the git regression suite fails
>>> with this kernel.
>>> ...
>>> A wire capture shows that some GETATTR operations receive
>>> an NFS3ERR_STALE response from the server. I looked at one
>>> of these, and it's against a renamed file "index.lock".
>>>=20
>>> So I reverted:
>>>=20
>>> commit 920b4530fb80430ff30ef83efe21ba1fa5623731
>>> Author:     Benjamin Coddington <bcodding@redhat.com>
>>> Date: Wed Feb 1 00:00:07 2017 -0500
>>>=20
>>> NFS: nfs_rename() handle -ERESTARTSYS dentry left behind
>>>=20
>>> And t9200 now passes:
>>=20
>> Yep, something seems to be wrong with calling
>> nfs_mark_for_revalidate(old_inode) in rpc_call_done instead of after
>> rpc_release.  Thanks for catching this.  I'm out of time today, and =
will
>> look at this in the morning.
>=20
> I found the test was doing something like:
>=20
> rename("/mnt/localhost/attic_gremlin,", =
"/mnt/localhost/attic_gremlin,v") =3D 0
> open("attic_gremlin", O_RDONLY) =3D 7
> open("attic_gremlin,v", O_RDONLY) =3D 8
>=20
> So, I think the problem is that patch moved the d_move() before
> d_rehash(new_inode).. so it's actually rehasing the old dentry's name. =
 I'm testing
> the following fix:

I applied this to my client, and was not able to reproduce the problem.

Tested-by: Chuck Lever <chuck.lever@oracle.com>


> =46rom 425f85c59142fe0821d30b11ba0df7704ebf6de6 Mon Sep 17 00:00:00 =
2001
> Message-Id: =
<425f85c59142fe0821d30b11ba0df7704ebf6de6.1489586013.git.bcodding@redhat.c=
om>
> From: Benjamin Coddington <bcodding@redhat.com>
> Date: Wed, 15 Mar 2017 08:06:38 -0400
> Subject: [PATCH] NFS: Fix old dentry rehash after move
>=20
> Now that nfs_rename()'s d_move has moved within the RPC task's =
rpc_call_done
> callback, rehashing new_dentry will actually rehash the old dentry's =
name
> in nfs_rename().  d_move() is going to rehash the new dentry for us =
anyway,
> so doing it again here is unnecessary.
>=20
> Reported-by: Chuck Lever <chuck.lever@oracle.com>
> Fixes: 920b4530fb80 ("NFS: nfs_rename() handle -ERESTARTSYS dentry =
left behind")
> ---
> fs/nfs/dir.c | 9 ++-------
> 1 file changed, 2 insertions(+), 7 deletions(-)
>=20
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index fb499a3f21b5..f92ba8d6c556 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -2055,7 +2055,7 @@ int nfs_rename(struct inode *old_dir, struct =
dentry *old_dentry,
> {
>    struct inode *old_inode =3D d_inode(old_dentry);
>    struct inode *new_inode =3D d_inode(new_dentry);
> -   struct dentry *dentry =3D NULL, *rehash =3D NULL;
> +   struct dentry *dentry =3D NULL;
>    struct rpc_task *task;
>    int error =3D -EBUSY;
>=20
> @@ -2078,10 +2078,8 @@ int nfs_rename(struct inode *old_dir, struct =
dentry *old_dentry,
>         * To prevent any new references to the target during the
>         * rename, we unhash the dentry in advance.
>         */
> -       if (!d_unhashed(new_dentry)) {
> +       if (!d_unhashed(new_dentry))
>            d_drop(new_dentry);
> -           rehash =3D new_dentry;
> -       }
>=20
>        if (d_count(new_dentry) > 2) {
>            int err;
> @@ -2098,7 +2096,6 @@ int nfs_rename(struct inode *old_dir, struct =
dentry *old_dentry,
>                goto out;
>=20
>            new_dentry =3D dentry;
> -           rehash =3D NULL;
>            new_inode =3D NULL;
>        }
>    }
> @@ -2119,8 +2116,6 @@ int nfs_rename(struct inode *old_dir, struct =
dentry *old_dentry,
>        error =3D task->tk_status;
>    rpc_put_task(task);
> out:
> -   if (rehash)
> -       d_rehash(rehash);
>    trace_nfs_rename_exit(old_dir, old_dentry,
>            new_dir, new_dentry, error);
>    /* new dentry created? */
> --=20
> 2.9.3

--
Chuck Lever
