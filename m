Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:40968 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754303AbdLTXNv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 20 Dec 2017 18:13:51 -0500
From: NeilBrown <neilb@suse.com>
To: Matthew Wilcox <willy@infradead.org>
Date: Thu, 21 Dec 2017 10:13:40 +1100
Cc: Al Viro <viro@zeniv.linux.org.uk>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH/RFC] VFS: don't keep disconnected dentries on d_anon
In-Reply-To: <20171220225604.GA2980@bombadil.infradead.org>
References: <87y3lxj9wr.fsf@notabene.neil.brown.name> <20171220225604.GA2980@bombadil.infradead.org>
Message-ID: <87vah1j8m3.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Wed, Dec 20 2017, Matthew Wilcox wrote:

> On Thu, Dec 21, 2017 at 09:45:40AM +1100, NeilBrown wrote:
>> -c/ Helper routines to allocate anonymous dentries, and to help attach
>> +   prefix.  If the refcount on a dentry with this flag set
>> +   becomes zero, the dentry is immediately discarded, rather than being
>> +   kept in the dcache.  If a dentry that is not already in the dcache
>> +   is repeatedly accessed by filehandle (as NFSD might do), an new dentry
>> +   will be a allocated for each access, and discarded at the end of
>
> s/a //
>
>> +   the access.  As there is no parent, children, or name in the dentry
>> +   is it unlikely that there will be any useful information to lose,
>> +   and allocating a new dentry should normally be fast.
>
> How about:
>
> As the dentry is completely unattached, there is little information to
> lose, and allocating a new dentry is normally fast.

Yes, that is less verbose, and probably just as informative.
Every time I rehearse this argument I wonder about d_fsdata.
I don't think it is actually relevant, but I feel that by not mentioning
it, I'm being dishonest...  Maybe I should think of it as being "less
distracting".

Thanks - if this gets far enough to deserve a resent, I'll add those
changes.

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlo67qQACgkQOeye3VZi
gbnmuw/+Nj4TLEpEQUbxd90fvpO+KC27FbT8gwBMZ3r4PuUS5xnUzwZ3uHse5WCx
HgPM9uxZ3B5rlERdcWAmJnbtTYCg7f8exN6jXDqVsNbTmO3OC2ql5hs4id3chvvh
rsFqkSplJs6QbU/KIBkZ8/QVLYdCXRh4owu0cYD7ze9Qj6oHAHEM4eCVdKlZOh6W
a+QOkwvUbemN3DafYjM1p2chamMF4RIxG/6Y2226cRR9IUXrWiw5QVT3QaTin57Z
nw0xmH2gErn6k6IJZOEdMY/duLcd2y2HMnhg8lfmaugtPQFH3dx+bxcKglNfT0tp
BKliWPj7qLq2Dw6vTHjHJr4N6tdoX2tuqeM3zKnHorVH4XpdE2t6uWmgy4DbLvEg
9auNsZai0ZUo/LwQtZGLKq1NPBGJ+V0j9ror5OIPuY0iTArrCbkE2TLgCZRsn+0F
HJQSfUoQxZs0kP8SFwq39z0qT/IolNTHfcoIgIM4/jEkXXhE/sflxnflIWysWCwl
0HzYshSvaEYPGM93W6i+UPbKC8u+APZyVYvSmBpeKEmMBPEih3J+KIK6KqvAjkgq
xWlWOnBr1R2eu7jnu/WQjV17g11rNa+zxfLrDJT7SLvHdCP9p0z/uc6laTGSSlKR
32ajLrxX8ihNCBpGEi7gFjb0Ws4WSVutsoIupvJRgcLZJiVfN1M=
=czHA
-----END PGP SIGNATURE-----
--=-=-=--
