From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH][RFC] NFS: Improving the access cache
Date: Wed, 26 Apr 2006 11:03:17 -0400
Message-ID: <444F8BB5.2000700@RedHat.com>
References: <444EC96B.80400@RedHat.com> <1146056601.8177.34.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Cc: nfs@lists.sourceforge.net, linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1146056601.8177.34.camel@lade.trondhjem.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Trond Myklebust wrote:
>=20
>=20
> Instead of having the field 'id', why don't you let the nfs_inode kee=
p a
> small (hashed?) list of all the nfs_access_entry objects that refer t=
o
> it? That would speed up searches for cached entries.
Actually I did look into having a pointer in the nfs_inode... but
what do you do when the second hashed list is needed. Meaning
P2(uid2) comes along and hashes to a different que. I guess
I thought it was a bit messy to keep overwriting the point in the
nfs_inode so I just kept everything in the hash table...

> I agree with Neil's assessment that we need a bound on the size of th=
e
> cache. In fact, enforcing a bound is pretty much the raison d'=C3=AAt=
re for a
> global table (by which I mean that if we don't need a bound, then we
> might as well cache everything in the nfs_inode).
Ok..

> How about rather changing that hash table into an LRU list, then addi=
ng
> a shrinker callback (using set_shrinker()) to allow the VM to free up
> entries when memory pressure dictates that it must?
Sounds interesting.. Just to be clear, by LRU list you mean use hlist
correct?

steved.

-
To unsubscribe from this list: send the line "unsubscribe linux-fsdevel=
" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
