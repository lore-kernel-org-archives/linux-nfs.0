From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH][RFC] NFS: Improving the access cache
Date: Wed, 26 Apr 2006 09:03:21 -0400
Message-ID: <1146056601.8177.34.camel@lade.trondhjem.org>
References: <444EC96B.80400@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: nfs@lists.sourceforge.net, linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <444EC96B.80400@RedHat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Tue, 2006-04-25 at 21:14 -0400, Steve Dickson wrote:
> Currently the NFS client caches ACCESS information on a per uid basis
> which fall apart when different process with different uid consistent=
ly
> access the same directory. The end result being a storm of needless
> ACCESS calls...
>=20
> The attached patch used a hash table to store the nfs_access_entry
> entires which cause the ACCESS request to only happen when the
> attributes timeout.. The table is indexed by the addition of the
> nfs_inode pointer and the cr_uid in the cred structure which should
> spread things out nicely for some decent scalability (although the
> locking scheme may need to be reworked a bit). The table has 256 entr=
ies
> of struct list_head giving it a total size of 2k.

Instead of having the field 'id', why don't you let the nfs_inode keep =
a
small (hashed?) list of all the nfs_access_entry objects that refer to
it? That would speed up searches for cached entries.

I agree with Neil's assessment that we need a bound on the size of the
cache. In fact, enforcing a bound is pretty much the raison d'=C3=AAtre=
 for a
global table (by which I mean that if we don't need a bound, then we
might as well cache everything in the nfs_inode).
How about rather changing that hash table into an LRU list, then adding
a shrinker callback (using set_shrinker()) to allow the VM to free up
entries when memory pressure dictates that it must?

Cheers,
  Trond

-
To unsubscribe from this list: send the line "unsubscribe linux-fsdevel=
" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
