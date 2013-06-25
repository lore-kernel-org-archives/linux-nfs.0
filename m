Return-Path: linux-nfs-owner@vger.kernel.org
Received: from haggis.pcug.org.au ([203.10.76.10]:46519 "EHLO
	members.tip.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751071Ab3FYBhS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Jun 2013 21:37:18 -0400
Date: Tue, 25 Jun 2013 11:37:04 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: Jeff Layton <jlayton@redhat.com>
Cc: viro@zeniv.linux.org.uk, matthew@wil.cx, bfields@fieldses.org,
        dhowells@redhat.com, sage@inktank.com, smfrench@gmail.com,
        swhiteho@redhat.com, Trond.Myklebust@netapp.com,
        akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
        linux-afs@lists.infradead.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        cluster-devel@redhat.com, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, piastryyy@gmail.com
Subject: Re: [PATCH v4 06/14] locks: encapsulate the fl_link list handling
Message-Id: <20130625113704.89a686a55dcec684e5e99434@canb.auug.org.au>
In-Reply-To: <1371819502-26363-7-git-send-email-jlayton@redhat.com>
References: <1371819502-26363-1-git-send-email-jlayton@redhat.com>
	<1371819502-26363-7-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__25_Jun_2013_11_37_04_+1000_dzYhDLAz_=0wCCci"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Signature=_Tue__25_Jun_2013_11_37_04_+1000_dzYhDLAz_=0wCCci
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Jeff,

Thanks for doing all this work!

Trivial comments below.

On Fri, 21 Jun 2013 08:58:14 -0400 Jeff Layton <jlayton@redhat.com> wrote:
>
> +static inline void
> +locks_insert_global_locks(struct file_lock *fl)
> +{
> +	list_add_tail(&fl->fl_link, &file_lock_list);
> +}

We generally do not use "inline" in C files any more and leave it to the
compiler to do that.  Also, without the "inline" these function headers
should all be able to fit on single lines like the others here i.e.

static void locks_insert_global_locks(struct file_lock *fl)

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Tue__25_Jun_2013_11_37_04_+1000_dzYhDLAz_=0wCCci
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJRyPREAAoJEECxmPOUX5FEfWIP/1Fcte7TTx0cYdMFqxD6iYFF
I5QuoxOCEek37xGFhXwztvoI+llIdSH4xYaZXtVyC01jxfejNfGOW6JOuxRWrMCW
4o0doZNE7fX1CaPJv+O8HS0qGVGVL4En0ZJJrPtjImbrUP1rg+bKAI4GwTZTcxfH
eDr8Oey4xzzSFR/am+e7IyEjAW4gA7EIOpG4PjcMP+LEbTKOaybUDZBs+IwRBiPL
ERyuwyW1mdAh5Cd5rssT72osOSq36WvK7f0w7hdzenmJFj5SUY4mmWdQz25J79ZC
5LOfPxcgZWAv48F4VmmKh0v555f7hVGdtf1eE4cwckzWDQAvvPY27xSFNaYWwvd9
jpDVPR0CcJeJkRR4qpGE6OO9dRGCoq8aNAmln0ix4ehb7+rGt4KMO0vOplFmfb1y
oiL/Uzc2WuoFJDQCU1f7Z3EmcBKZBxS+Hs67xuvulBAubLY4r0uYMcA6RLgsbHB7
k/eyUk9Rsce39jdPNPkFM1AB92F5AvdmaqROH2NKRh9lNOmZDNxxQ3v/9XU9oY6t
1uNs9dL7H9f2MaMeG4Yx9ircj+NdB7vwbauYlAv/9D1fxRhqoKO1M292CbWhv/l0
OwcF9Nz9e6aHHZc8HnZzlKjzRaoqJ83eFekWk4RZbmNhEmlLDzHUXfqrke6fn8pn
Y1vM5HPDCfSDb/sVAmbd
=q+vx
-----END PGP SIGNATURE-----

--Signature=_Tue__25_Jun_2013_11_37_04_+1000_dzYhDLAz_=0wCCci--
