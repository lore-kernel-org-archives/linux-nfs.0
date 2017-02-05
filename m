Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:46558 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751923AbdBEW3F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 5 Feb 2017 17:29:05 -0500
From: NeilBrown <neilb@suse.com>
To: Kinglong Mee <kinglongmee@gmail.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Date: Mon, 06 Feb 2017 09:28:55 +1100
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Kinglong Mee <kinglongmee@gmail.com>
Subject: Re: [PATCH] sunrpc/cache: skip checking the pending cache expired
In-Reply-To: <e87e2700-3eb3-19cc-a2ca-675ff1219aa8@gmail.com>
References: <cb2a552c-51ec-f230-0b39-0bd4002e351d@gmail.com> <4471ba20-2677-f9f4-dc27-c53b50c72066@gmail.com> <e87e2700-3eb3-19cc-a2ca-675ff1219aa8@gmail.com>
Message-ID: <871svcxoew.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, Feb 05 2017, Kinglong Mee wrote:

> On 2/5/2017 18:37, Kinglong Mee wrote:
>> On 2/4/2017 13:41, Kinglong Mee wrote:
>>> When the first time pynfs runs after rpc/nfsd startup, always get the w=
arning,=20
>>>
>>> Got error: Connection closed
>>>
>>> Commit 778620364ef5 "sunrpc/cache: make cache flushing more reliable." =
lets
>>> cache_is_expired() checking expired as,=20
>>>
>>> return (h->expiry_time < seconds_since_boot()) ||
>>>         (detail->flush_time >=3D h->last_refresh);
>>>
>>> The detail->flush_time is equal to h->last_refresh time, when the cache=
 is
>>> new created and then do the upcall immediately. So that, the cache will=
 be
>>> treated as expired and be cleaned when write_flush().
>
> I found the problem is caused by,=20
> 1. A new startup of nfsd, rpc.mountd, etc,
> 2. A rpc request from client (pynfs test, or normal mounting),
> 3. An ip_map cache is created but invalid, so upcall to rpc.mountd,=20
> 4. rpc.mountd process the ip_map upcall, before write the valid data to n=
fsd,
>    do auth_reload(), and check_useipaddr(),
> 5. For the first time, old_use_ipaddr =3D -1, that cause a cache_flush,
> 6. The ip_map cache will be treat as expired and clean,
> 7. When rpc.mountd write the valid data to nfsd, a new ip_map is created
>    and updated, the cache_check of old ip_map(doing the upcall) will
>    return -ETIMEDOUT.
> 8. RPC layer return SVC_CLOSE and close the xprt after commit 4d712ef1db05
>    "svcauth_gss: Close connection when dropping an incoming message"
>
> Although it is exist only one time, but I don't like the noise.
> Is the cache_flush for old_use_ipaddr =3D -1 necessary in step 5?
> I have no idea about how to fix it, any suggests?
>

Hi,
 I think that your idea that CACHE_PENDING cache entries shouldn't be
 treated as expired make some sense.
 I would actually focus on CACHE_VALID.  If CACHE_VALID is not set, then
 there is no data in the cache item, so there is nothing to expire.
 So it would be nice if cache items that don't have CACHE_VALID are
 never treated as expired.
 However, as you discovered, that causes a problem for cache_purge().
 It purges a cache by setting the ->flush_time, and calling
 cache_clean(), which only removes expired entries.  For that to work,
 Even non-CACHE_VALID entries need to be seen as expired.

 I think the best thing to do is to write a stand-alone cache_purge().
 Rather than using cache_flush(), explicitly free every item on every
 hash chain.

 Something like this?

static int cache_purge(struct cache_detail *cd)
{
	int rv =3D 0;
	struct list_head *next;
	int i;

	write_lock(&cd->hash_lock);

	for (i =3D 0; i < cd->hash_size; i++) {
		struct cache_head *ch =3D NULL;
		struct cache_detail *d;
		struct hlist_head *head;
		struct hlist_node *tmp;

		head =3D &cd->hash_table[i];
		hlist_for_each_entry_safe(ch, tmp, head, cache_list) {
			hlist_del_init(&ch->cache_list);
			cd->entries--;

			set_bit(CACHE_CLEANED, &ch->flags);
			write_unlock(&cd->hash_lock);
			cache_fresh_unlocked(ch, d);
			cache_put(ch, d);
			write_lock(&cd->hash_lock);
		}
	}
	write_unlock(&cd->hash_lock);

	return rv;
}

Thanks,
NeilBrown


> thanks,
> Kinglong Mee
>
>>>
>>> This patch skips checking the pending cache expired when doing upcall.
>>>
>>> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
>>> ---
>>>  include/linux/sunrpc/cache.h | 5 ++++-
>>>  1 file changed, 4 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
>>> index 62a60ee..9961c1f 100644
>>> --- a/include/linux/sunrpc/cache.h
>>> +++ b/include/linux/sunrpc/cache.h
>>> @@ -204,8 +204,11 @@ static inline void cache_put(struct cache_head *h,=
 struct cache_detail *cd)
>>>  	kref_put(&h->ref, cd->cache_put);
>>>  }
>>>=20=20
>>> -static inline int cache_is_expired(struct cache_detail *detail, struct=
 cache_head *h)
>>> +static inline bool cache_is_expired(struct cache_detail *detail, struc=
t cache_head *h)
>>>  {
>>> +	if (test_bit(CACHE_PENDING, &h->flags))
>>> +		return false;
>>> +
>>=20
>> Sorry, with this patch there is a bug exist,
>> When a pending cache exist, sunrpc_destroy_cache_detail() cann't
>> cleanup the cache_detail, but user always free it later,=20
>> that will cause a NULL reference.
>>=20
>> Please ignore this patch, maybe another patch for the above problem
>>  will be sent.
>>=20
>> thanks,
>> Kinglong Mee
>>=20
>>>  	return  (h->expiry_time < seconds_since_boot()) ||
>>>  		(detail->flush_time >=3D h->last_refresh);
>>>  }
>>>
>>=20

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAliXpycACgkQOeye3VZi
gbl+fA/+Kq8Ms9af6QMeGo1ioh/Vw/HCu3pJTMpCoFpu4O2FuSHjwCrXkMWDNTqE
wF1sfJKsT7gb+EFC3bEt4RyEp5ttyMwLkt/12cjS6r075qS1vV3Ly4lecN55NARK
Vv/epkWNDMqcq5INbbStdo/2+VDSUE0xrlD/H8LGmGm4UX5gpU7l/KQS2YA1BJzB
GmUNRhRQCO8Cy/Mq7vWvu8BK8EaQslkV6Bu981WbLOWoPM/+DESAsnxbYrAzdioB
26Jlh776M3QZFGMrFvP16VBnj6xt2L0HHWvqJONeq06KQRHpPlmJ0nv+nXjcH+n/
PwxWNVDyyfkqg9o6pDnac2a/4N8gP72rPtvNmmbO9CgbihOwz+0p8tUn8D005iKx
SnL3ek4JneuxodBW/zMruwHRF9eVxSw0YIxhG536aPzItVldlZk7HczurdU3EoK3
sOR3IhwBoj0pg4TK/RGci5l8gmOyjS31NSaPjEQa8xIsyfWdOPZfd0nYs0WsAxKK
xUN8fKGdrd3sMRjxn5Zh2/TQg8Lvxgq3hYPAljPm++f+ZDzUG8RzcqHWO4I496Eq
BumHsQ1owh7fJ6+l6u5507LRjllqiJc2UNXHcDsa0MvmIUgMANxNcuJcjBxtKFhr
AsYXcJSNUra3oNS264dwy/USJrM7xb2TH+s+Z2WBTkbFMwPvzus=
=yW6A
-----END PGP SIGNATURE-----
--=-=-=--
