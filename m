Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:49741 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751071Ab1KNB0U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 13 Nov 2011 20:26:20 -0500
Date: Mon, 14 Nov 2011 12:26:06 +1100
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>,
        Christoph Hellwig <hch@infradead.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Matthew Treinish <treinish@linux.vnet.ibm.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH/RFC 0/7] Volatile Filehandle Client-side Support
Message-ID: <20111114122606.63c6e471@notabene.brown>
In-Reply-To: <20111114004254.GA30681@fieldses.org>
References: <1321052673-22171-1-git-send-email-treinish@linux.vnet.ibm.com>
	<1321056809.8733.2.camel@lade.trondhjem.org>
	<20111112144953.GA3740@infradead.org>
	<20111113145400.6c7a9be3@notabene.brown>
	<CAGue13r5BhjWOUF3L8Jd4_T0RmOwL7D=ktwHT_7paug5qEvKmA@mail.gmail.com>
	<20111113163632.GA28574@fieldses.org>
	<20111114080745.57083bfe@notabene.brown>
	<20111114004254.GA30681@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/Jy102EYhK9Q0BzaOZHQhPlR"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/Jy102EYhK9Q0BzaOZHQhPlR
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sun, 13 Nov 2011 19:42:54 -0500 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Mon, Nov 14, 2011 at 08:07:45AM +1100, NeilBrown wrote:
> > On Sun, 13 Nov 2011 11:36:32 -0500 "J. Bruce Fields" <bfields@fieldses.=
org>
> > wrote:
> >=20
> > > On Sun, Nov 13, 2011 at 02:45:48PM +0100, Tigran Mkrtchyan wrote:
> > > > I have a server which runs on top of hadoop. The problem with hadoop
> > > > is that there is no way to have persistent file handles. I am
> > > > currently working on a way to do that - either simulate them or add=
 a
> > > > support for unique file id to hadoop. If linux client will support
> > > > volatile file handles then I can stop inventing some workarounds.
> > >=20
> > > I might call that "fixing" rather than inventing workarounds.
> > >=20
> > > Our of curiosity: if we really wanted to support such filesystems, wh=
at
> > > would we need in the protocol?  Just saying "filehandles aren't stabl=
e,
> > > deal with it" seems insufficient.=20
> >=20
> > 1/ no guarantees if the file is not 'open'
> > 2/ two possible responses to FHEXPIRED:
> >     a/ perform a GETATTR and request the 'filehandle' attribute.  Clien=
t then
> >        uses that filehandle instead.
> >     b/ perform LOOKUP on parent filehandle with same name as before, an=
d use
> >        the resulting filehandle.
> >    Server specifies which somehow (different error code?  magic attribu=
te
> >    flag somewhere?  doesn't really matter)
> >=20
> > If a server has objects that are never renamed, it can easily use volat=
ile
> > file handles.
> > If a server has objects which can be renamed and wants to use volatile =
file
> > handles, then if such an object is open and is about to be renamed, it =
must
> > first log to stable storage some mapping to allow it to access the file=
 from
> > the old volatile file handle.
>=20
> I think then there's no limit to the lifetime of those log entries, or
> to the size of the log?

The lifetime of the log entry matches the lifetime of an 'open', just like
any state that the server holds on behalf of a client.  They can be discard=
ed
on last close, or when you haven't heard from the client for the lease-time.

The size of the log is bounded by the maximum number of allowed clients, and
the maximum number of concurrent opens per client.  i.e. it is the same ord=
er
and the amount of open state that the server needs to store at any one time.

So the only really 'new' thing here is that more of the state needs to be on
stable storage - it isn't really substantially more state.

NeilBrown

--Sig_/Jy102EYhK9Q0BzaOZHQhPlR
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBTsBuLjnsnt1WYoG5AQK3yg/9FTTp0xHNn05OqDYTfpWRIinPBMG9+AG6
iyNPJaQwVcg2ghtqZIKbdL4Be4alWBlU71SplMfaTioDAmGbCL7Bh0fAXuBk3wk9
viShcf9A2+ayQb8p03WaOkjR7zzaxEWLS78xepuGrYOJJlpgrSDVAxeybGHQjOpC
MEc+1UOZI7Rz+zTqOx904thMUJCJzYEGfnVMQfzaA8UzK85krgqIqN/bZh+pHzl9
o6tbzN35OmdmqqwMnn+1mWs6+AuPnTCC604sZl60PyULbGV50ZNh+KVMj1DD1qJt
h8sZETtLMtjs328XZvbPLJO9iPjnyBMNUViFKntkGovI6Td6o4pKIZORSEpDVksZ
UBVzWkNG+/IJAaIM/AKV9eHuXk6FZZEhJ2zF9HpxEhNhPwmbki53rRzAP2nvDJBQ
bFCyW8rENNrOImXHgtEPfX5O327cszxvI7/qIxzVqEzmmolUMkkPsncgU4hoxgYA
wK6VTZFGBEOXh0JSF2VZX3pF7yiBtx+Msu15dOR6s8kd1opRi1YA3PUIYBUpg9rY
PlfUkkEB8Ky6G7HiTbaFAi5QcFVYgiVY1ByMngvqm++W7i2Aclu0YCwg7LVrFxtd
1v5ZWGi8tIALPq5B5BqBbbIXhaATp54fUCKP8FITFbpSTF3kvc8b47MePnjpv5Ki
FxdkWU9pxOk=
=Y059
-----END PGP SIGNATURE-----

--Sig_/Jy102EYhK9Q0BzaOZHQhPlR--
