Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:38390 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751327AbcLFWNL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Dec 2016 17:13:11 -0500
From: NeilBrown <neilb@suse.com>
To: Olga Kornievskaia <aglo@umich.edu>
Date: Wed, 07 Dec 2016 09:12:59 +1100
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        Olga Kornievskaia <kolga@netapp.com>
Subject: Re: [PATCH] SUNRPC: fix refcounting problems with auth_gss messages.
In-Reply-To: <CAN-5tyHT9X9ULCDT0iPkMtgo4eMiRLVGVuzabmZXMePv8FwXFw@mail.gmail.com>
References: <87oa0r584c.fsf@notabene.neil.brown.name> <CAN-5tyHrWMj54cvj3PVO+8Yxk+0NK9ey=X7VU6WXKv-mswh-xw@mail.gmail.com> <877f7e58yo.fsf@notabene.neil.brown.name> <CAN-5tyHT9X9ULCDT0iPkMtgo4eMiRLVGVuzabmZXMePv8FwXFw@mail.gmail.com>
Message-ID: <87wpfc4sgk.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Wed, Dec 07 2016, Olga Kornievskaia wrote:
>>>
>>> Agreed. This is a problem.
>>>
>>> Doesn't the problem still exist even with this patch because
>>> gss_add_msg() adds the msg onto the in_downcall() list? So gssd in
>>> __gss_fin_upcall() can find the 2nd upcall even before the 2nd msg is
>>> added to the pipe->pipe()?
>>
>> The use-after-free problem is solved I think.  It doesn't really make
>> any difference if the down-call arrives before or after
>> rpc_queue_upcall() is called.  The msg will still not be freed before it
>> is removed from both lists.
>>
>
> Sorry I don't see it.

Maybe we are looking at different code?

>
> Thread 1 adds an upcall and it's getting processed by gssd.
> Thread 2 executes gss_add_msg() which puts the message on the
> in_downcall list. Context switch (before the atomic_inc()!).

gss_add_msg(), as of 4.9-rc8, is
	spin_lock(&pipe->lock);
	old = __gss_find_upcall(pipe, gss_msg->uid, gss_msg->auth);
	if (old == NULL) {
		atomic_inc(&gss_msg->count);
		list_add(&gss_msg->list, &pipe->in_downcall);
	} else
		gss_msg = old;
	spin_unlock(&pipe->lock);

so the gss_msg is added to in_downcall *after* the atomic_inc(), and the
whole is protected by pipe->lock anyway so even if the atomic_inc() were
delayed by the CPU reordering things, there would be no risk of
gss_pipe_downcall() finding a gss_msg which didn't have the ->count
elevated.

NeilBrown

> Upcall comes back from the gssd, finds msg from Thread2 in_downcall
> list. gss_release_msg() will dec the counter to 0 and will remove the
> msg.

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlhHN+wACgkQOeye3VZi
gbnb7Q//eXKoyu7LTJM+3WsGVna3lP8C37R/9wO3mWM4yRjucGDLRLf6cHrAn+c2
OHAdHg/+6cSvaaYwcQANKAOcytqVxAlOcJ13BnWkjH30Uhwm4E5108gtefzxG80F
lyxWP/DXuDepoVD4EvGHIesUUZZAm7nViKkV6931nIMFCvq3oK9Pcb1h+TflN7S7
PbwXi7gvy/GxALYwwXo7mm/81SwrD85MD/Q41ZmN3DeC+RwebzGVbl9FrDVbewWz
unqVMniPAAzrXiDX77FKl4QxN27HGs4xHkFkJx7KPGyhHLAzF/WI49tpMkwIJja2
ShM0JV42zmUIww1iBDJ0fx9jFylRurBNYx7VPGZURutCIyWdL09dIcZYIzv0hats
yl0vX3GEf6XbrUPmqiIdkdJclOu2PCjYovy92cIxhwX4dzF1La4PwEph4npvv0kK
qUWbsQHVrn8BoPcPGn2jI68fYYfjVrW46sYZLG066l0ERJ8KLwDBYd+cpgagwkFG
nhYg8JX/E0MoXgkGZghWQOLC5dEVNuWNGg8JUHFEwzzMhMCgI0gf98ty9pi3Q9pi
HrzO//LjZ9c0GR6hClVdUQtlfFtl7ixVQ9AyeGCYfaNgL8RYIeBDFKMBsvm+cCbp
3dE9Ypi7PhUzCGtOk/vOG7UG73o0MGIcMvDb8Q3KPmW6gqJ6ELg=
=FC62
-----END PGP SIGNATURE-----
--=-=-=--
