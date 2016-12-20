Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:46178 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753396AbcLTD5e (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Dec 2016 22:57:34 -0500
From: NeilBrown <neilb@suse.com>
To: andros@netapp.com, bfields@fieldses.org
Date: Tue, 20 Dec 2016 14:57:26 +1100
Cc: neilb@suse.de, linux-nfs@vger.kernel.org,
        Andy Adamson <andros@netapp.com>
Subject: Re: [PATCH Version 3] SVCAUTH update the rsc cacue on RPC_GSS_PROC_DESTROY
In-Reply-To: <1482192030-19219-1-git-send-email-andros@netapp.com>
References: <1482192030-19219-1-git-send-email-andros@netapp.com>
Message-ID: <87d1gntfq1.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Tue, Dec 20 2016, andros@netapp.com wrote:

> From: Andy Adamson <andros@netapp.com>
>
> I instrumented cache_get, cache_put, cache_clean, svcauth_cache_lookup
> and svcauth_gss_accept.
>
> Then I mounted -o sec=krb5, listed the mount directory, and umounted.
>
> CASE 1: Here is the instrumented output without the patch:
>
> svcauth_gss_accept gc_proc 3 rq_proc 0  (process RPC_GSS_PROC_DESTROY)
> --> sunrpc_cache_lookup from rsc_lookup key ffffc90002b9bc58 hash 940
> sunrpc_cache_lookup 1 calling cache_get key ffffc90002b9bc58 tmp
> ffff880079b3f500
> --> cache_get h ffff880079b3f500 refcount 1
> sunrpc_cache_lookup RETURN 1  key ffffc90002b9bc58 tmp ffff880079b3f500
> --> rsc_free h ffffc90002b9bc58
>
> &rsci->h is ffff880079b3f500, which identifies the cache entry we want
> destroyed.
>
> Case: RPC_GSS_PROC_DESTROY:
> svcauth_gss_accept RPC_GSS_PROC_DESTROY h ffff880079b3f500 ref 2
> expiry 1481823331 <<<<<
> svcauth_gss_accept AFTER SETTING h ffff880079b3f500 expiry 1481819736   <<<<<<<
>
> Note: expiry_time (and CACHE_NEGATIVE) are set.
>
> END of svcauth_gss_accept:
> svcauth_gss_accept END calling cache_put h ffff880079b3f500
> --> cache_put h ffff880079b3f500 refcount 2 cd->cache_put ffffffffa045c180
> Dec 15 11:35:36 rhel7-2-ga-2 kernel: <-- cache_put h ffff880079b3f500 refcount 1
>
> refcount is 1, but cache_clean is not setup to reap the entry as
> rsc_update was not called.

What exactly do you mean by "cache_clean is not setup to reap the entry"?

I think the problem is that detail->flush_time hasn't been updated to
match the new (reduced) ->expiry_time.  If that is what you meant by the
above, I completely agree.


>                             Besides using the write_lock (which should
> be used for entry changes) rsc_update also sets other fields to
> trigger cache_clean to remove the entry from the cache_list under
> the write_lock and do a final cache_put.

The write_lock is needed for some changes, but not necessarily all.
e.g. just clearing a bit is already atomic, so doesn't need a lock.
Decreasing ->flush_time to match a new ->expiry_time does need the lock
as it needs to be atomic.

I'll comment on the patch separately.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlhYrCYACgkQOeye3VZi
gblmLBAAjodyDcBu7O+P4xCgOhHPf20ZOayGMPDktCoojoUpv6WnG2yUqxiYLJ4M
WievYE6X2YEqKx7isMj81Pbwn+cS/SKGL+aNAXhUg6DHwS2zZTFvW6VOmyV6Rztd
OsRf6efdNxvcvMKgv9Oy2R2BdyAD4KYvmiU86iGa3PZt+Dq8+UU+01shsoWz8eGF
UEwZ+1Ht7W5O32HQ3ek2oY4QNFR+n25uI4EESz6mwC+veI1aRSUhGkCWSDEgEbma
TEtwh8XdhqzqUjHZAfOvWuF/ICLfpeVKnS466hR2sFDrrsJy+7FlWZkObh62aiSa
QxM5PBHqZOIIyN0CjhiVa3wLwpXuXW9A4usCVbW67rqDr8HdXmKR4lK+ifr0lAEz
iMHB9HXPb0cOFrFq3LxhB4l0oF2o2rKl46NqhMNK2Rl2xO5hc++XbpkvkTHe6avf
pEaP09ouym7T4F/HzKr39JRg8yiYeIibPGow3f+0tS0QuARLXP7GJcvzoC3YJdqZ
eBS6X0R0Fg3hV8p2hNCw9rdXxnoIWOX6BCyP4+1HCjZCsRUAzqY9LW2WAxWfttuO
wGUTRDWnhjCkCd7cscgYwD6Rd9doNJIgqeCgkQSasNBFBYuN0BtHEaq8iQIMbiRT
MODbcQEdrLsZyY+a4xaweMZ8/DewzKtPgAS3YfB3yT3/0rD06qg=
=0F2e
-----END PGP SIGNATURE-----
--=-=-=--
