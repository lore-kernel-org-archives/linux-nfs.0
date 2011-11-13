Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:38195 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753216Ab1KMDyM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 12 Nov 2011 22:54:12 -0500
Date: Sun, 13 Nov 2011 14:54:00 +1100
From: NeilBrown <neilb@suse.de>
To: Christoph Hellwig <hch@infradead.org>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Matthew Treinish <treinish@linux.vnet.ibm.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH/RFC 0/7] Volatile Filehandle Client-side Support
Message-ID: <20111113145400.6c7a9be3@notabene.brown>
In-Reply-To: <20111112144953.GA3740@infradead.org>
References: <1321052673-22171-1-git-send-email-treinish@linux.vnet.ibm.com>
	<1321056809.8733.2.camel@lade.trondhjem.org>
	<20111112144953.GA3740@infradead.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/A_VzDHN9BdS8JaXsy0pgKp+"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/A_VzDHN9BdS8JaXsy0pgKp+
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sat, 12 Nov 2011 09:49:53 -0500 Christoph Hellwig <hch@infradead.org>
wrote:

> On Fri, Nov 11, 2011 at 07:13:29PM -0500, Trond Myklebust wrote:
> > On Fri, 2011-11-11 at 18:04 -0500, Matthew Treinish wrote:=20
> > > This patch series implements client side support for volatile file ha=
ndle
> > > recovery (RFC 3530 section 4.2 and 4.3) with walk back using the dcac=
he. To
> > > test the client you either need a server that supports volatile file =
handles or=20
> > > you can hard code the server to output NFS4ERR_FHEXPIRED instead of
> > > NFSERR_STALE. (See the last patch in the series)
> >=20
> > WHY do we want to support this kind of "feature"? As you said, the RFC
> > doesn't actually help in figuring out how this crap is supposed to work
> > in practice, so why do we even consider starting to give a damn?
>=20
> *nod*. Pretending we handle it seems fairly dangerous.  I'd much prefer
> outright rejecting it.

Hence the suggested mount option.

A server might not be able to provide stable file handles, but can ensure
that files don't get renamed - for these filesystems, the name is a
reliable stable handle for the file (it just doesn't fit in the NFSv4 file
handle structure).

So if you know the filesystem will only return FHEXPIRED for filehandles
belonging to files that cannot be renamed, then it is perfectly reasonable =
to
repeat the name lookup to re-access the file after the server forgets about
an old filehandle.  The mount option is how you communicate this knowledge,
because the RFC doesn't provide a way to communicate it.

NeilBrown



--Sig_/A_VzDHN9BdS8JaXsy0pgKp+
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBTr8/WDnsnt1WYoG5AQJThhAAp/2svBIlNw1ctzuZ5yCqvP5E2V6F/HiV
rOuYLW8KQRuMEgXYdXF87WVKpPzTvASlJCL1PmUiqf0sJ0AgVi2ZO0TzPVqspr/2
h6McaqxERRxJMPw6r1C7B9QBXchTu6Yiw0FZuLcTnEva9/ZCwQCNrjWLwSOVcYqp
ysQje+tyusXSMbpFx66EvjcasiCKGj2T+9vXwYTMlx/M3jssHmLDWlwtauxxjlck
g+Tqh/u4mmwQUC9RIVFGeXN6/hU6DTAEPuRpILqxMn+pOzcqoMpBTSeL6gHsrY6X
OTA30axTELAq7zoW8m9Cp6HftKdppWIbjGBbzu4Bkd2ThZJQ3M1ys0rYEPqjRXBE
EKueGY56uPIqtSp5NpIPjmmkqs+Db1lqw4Z7hU6z7tBkG4Wd38hAwWy28HAgXaU1
2x9oPuTgd6pcMGmg/8SnptYZpFDcUwZCitUxKhcrn7hUaHxfCzOhuiuXZhnr0NVZ
45PoD6vPTjTCqXrB68bZviikYc+0fJ1d4dFN7lcwIPs/wziE4tMahbyTJaB1HwVm
t2p4DxltJqY346SOyZB4d6/5sneGYnDwpBzCBrTp2aBpewbARovnwCaJ2JN4tQ0A
VZxi6C4sClaz2tiIPaTkraIBCE0ZW/ud1LEFdZW51rdIOf6fjRk+5oRrxBf1eBTg
sKup+lvjEgI=
=gpz/
-----END PGP SIGNATURE-----

--Sig_/A_VzDHN9BdS8JaXsy0pgKp+--
