Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:39867 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751388Ab1KMVIJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 13 Nov 2011 16:08:09 -0500
Date: Mon, 14 Nov 2011 08:07:45 +1100
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>,
        Christoph Hellwig <hch@infradead.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Matthew Treinish <treinish@linux.vnet.ibm.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH/RFC 0/7] Volatile Filehandle Client-side Support
Message-ID: <20111114080745.57083bfe@notabene.brown>
In-Reply-To: <20111113163632.GA28574@fieldses.org>
References: <1321052673-22171-1-git-send-email-treinish@linux.vnet.ibm.com>
	<1321056809.8733.2.camel@lade.trondhjem.org>
	<20111112144953.GA3740@infradead.org>
	<20111113145400.6c7a9be3@notabene.brown>
	<CAGue13r5BhjWOUF3L8Jd4_T0RmOwL7D=ktwHT_7paug5qEvKmA@mail.gmail.com>
	<20111113163632.GA28574@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/tz/QxLdoYLLg_tRfqKK/cM6"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/tz/QxLdoYLLg_tRfqKK/cM6
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sun, 13 Nov 2011 11:36:32 -0500 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Sun, Nov 13, 2011 at 02:45:48PM +0100, Tigran Mkrtchyan wrote:
> > I have a server which runs on top of hadoop. The problem with hadoop
> > is that there is no way to have persistent file handles. I am
> > currently working on a way to do that - either simulate them or add a
> > support for unique file id to hadoop. If linux client will support
> > volatile file handles then I can stop inventing some workarounds.
>=20
> I might call that "fixing" rather than inventing workarounds.
>=20
> Our of curiosity: if we really wanted to support such filesystems, what
> would we need in the protocol?  Just saying "filehandles aren't stable,
> deal with it" seems insufficient.=20

1/ no guarantees if the file is not 'open'
2/ two possible responses to FHEXPIRED:
    a/ perform a GETATTR and request the 'filehandle' attribute.  Client th=
en
       uses that filehandle instead.
    b/ perform LOOKUP on parent filehandle with same name as before, and use
       the resulting filehandle.
   Server specifies which somehow (different error code?  magic attribute
   flag somewhere?  doesn't really matter)

If a server has objects that are never renamed, it can easily use volatile
file handles.
If a server has objects which can be renamed and wants to use volatile file
handles, then if such an object is open and is about to be renamed, it must
first log to stable storage some mapping to allow it to access the file from
the old volatile file handle.  And of course it cannot allow renames during
the grace period, but I think we already have that.
Also, if the VFH is such that it will be  lost on a reboot, the server must
log it to stable storage before allowing an open.

>=20
> Say there was some way for the client to indicate which filehandles it
> currently has in use, and some way for the server to ask the client to
> return in-use filehandles if there are too many (like DELEG_RECALL_ANY).
> Then the server could at least place a limit on the number of
> filehandles that it had to guarantee persistent.
>=20
> And/or the client could get a callback on rename/link/unlink.  Bah.
>=20
> Would any of that actually be easier than implementing persistent file
> handles?

Easier for whom?  Should NFSv4 be designed to make life easier for filesyst=
em
implementers, or easier for NFS implementers :-?

While I don't have concrete examples I would not be surprised if there were
filesystems where implementing limited persistence was practical while
implementing universal persistence was not.


NeilBrown


--Sig_/tz/QxLdoYLLg_tRfqKK/cM6
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBTsAxpznsnt1WYoG5AQLxAQ//S1rR1Ys3CC9HVEXLcBvSVCKnWD+sf+Y/
jwi7DHXeVTgceYYpkpoksnJ7afCclAQ0UN4P5WRPnlX1297kdNQ22ma3bM2p+lXC
ClKy1pgvCfN7ta1+ZBOHq7N6H2FdF7a+QEtTbG10LKPJe6vS71kvtphyebvduIsg
JyaLOj3a4h+wlVobelNrtPn/SZvRdVcgTX9x6Dqf1M/U6f4eckJ/y1NeC0tkutBG
tU1yFHSM/7AOjxAdOypAry2Mya5dtdJkpWr5UT5r4om3LWe2Oy6IgyFEzJfOJl19
iChfxN5/7bp1ul4dfgoHgwAZjblwuzKD9IM/izBp1+yKmiewrC7qZMO5teJvZyil
JLeF8R2d43QV0Rc4JTTnSc/iYrsdfLixnKdI5p5iz6YK8icJXu/G+c6Fd3Sfr62G
KSt6AWSZgyjrn7lQBD4d1Ko43a6loSbgwPveaK88lF/KJN+gWNK45kBbK0rQhYZG
TJZwkhZ58CKDwHGsPi7wos+n9v3VhT5hMNNqvqY+RUadht5W+sQI/jMuPcpwMnmn
6b2NLA/n7IpWs7sqNLqK/gV0298WJ80zkTPQT3od17FbiLj1npaKvMHD/7NF6+kZ
ymblmWMA9UXTJIDS38y7kSzg4sEldtOyIxidb0R7F199AAMIbS3FTGhkqwyifauc
A9kGd5TWqYM=
=ez0/
-----END PGP SIGNATURE-----

--Sig_/tz/QxLdoYLLg_tRfqKK/cM6--
