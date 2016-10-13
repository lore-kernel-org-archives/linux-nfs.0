Return-Path: <neilb@suse.de>
From: NeilBrown <neilb@suse.com>
To: Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Thu, 13 Oct 2016 15:15:31 +1100
Cc: Benjamin Coddington <bcodding@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/5] NFSv4: change nfs4_select_rw_stateid to take a lock_context inplace of lock_owner
In-Reply-To: <1476275602.2541.20.camel@redhat.com>
References: <147623977637.19592.12766016823334433969.stgit@noble> <147623995856.19592.8461168656619949864.stgit@noble> <1476275602.2541.20.camel@redhat.com>
Message-ID: <878tts28bg.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Wed, Oct 12 2016, Jeff Layton wrote:

>> -	fl_owner = lockowner->l_owner;
>> +	if (l_ctx == NULL)
>> +		fl_owner = current->files;
>> +	else
>> +		fl_owner = l_ctx->lockowner.l_owner;
>
>
> This I'm less sure of. Suppose we have only a flock lock on a file and
> then truncate it. This is going to miss finding that stateid, no?
>
> I wonder if we need to look harder at the state to determine which owner to use in this case?

I didn't think this was possible with the current API, but I had
forgotten about (or never knew about) ATTR_FILE.
setattr does have access to the file, so it can find all the nfs state
info needed.
And when I modify the patch series to make use of that, it removes some
ugly bits :-)

I'll repost after a little testing.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJX/wpjAAoJEDnsnt1WYoG5aecP/3Wmwu/7Nk+LaR/qjDCwaTpu
JFQawJhRXZK2xvVGG6f1xaeN/IGHPp0C9+k+rm+oQlzFZN2NUOR48pbhdMv3+i1b
8K0buOUJfi4hcSSQ/bDYLN2gfInpK64LqTlQCSWV6lQLW6JTmYBgmGd6K8F2UCZ6
foVVNAfnMvoCz3tflhKVl/UQ4FKKUNf6r7Kn53531doMSyQKd+OPBP9w4JDAB18g
Mt3YM0AZxdK0AZiznfkH3vJwcUvj0kchl23ZSu07eODeWrL37zWdk9f6A53Cpzav
alH3Ttf/quUegiMGRJ0rB4tm2mwoGc2g44w1PwUnTC7qTiHi9KtKX3DsoY7Etf13
9mTC4963eGBrIl0Z5KriNeADTJgpNtudzdPzdEmGTDyr8HcQYiqYla2MKPudOSzd
CHDTWolg7L35FubdPnWqhf6xi9CiB1pG+1QvffZDtUauN8zlDaE3j84tbKTJqqEU
gNXkinq3u7Q8YtkNrPLmMgXCqWgIvXxUVVp/S+xXRkgknnfh0pQnQ2Pw7AW5ymwv
7lu9iY7mlykW+Ebg/jDcVkT1Grnxte/nLm++09VloZzRvBgFskwuvqdS7ROxcndt
z1m9kpjnXEibJIbFyZ8Se1RyXMWXAu5P+Xb0qG2vsmX5tM3D140NGJ0SohPH3Gqx
E34sStA6vXOCONXWpXtZ
=bTtm
-----END PGP SIGNATURE-----
--=-=-=--
