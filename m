Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:45899 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752241AbaCFDfE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Mar 2014 22:35:04 -0500
Date: Thu, 6 Mar 2014 14:34:54 +1100
From: NeilBrown <neilb@suse.de>
To: Jim Rees <rees@umich.edu>
Cc: Andrew Martin <amartin@xes-inc.com>, linux-nfs@vger.kernel.org
Subject: Re: Optimal NFS mount options to safely allow interrupts and
 timeouts on newer kernels
Message-ID: <20140306143454.75eb2726@notabene.brown>
In-Reply-To: <20140305211124.GA16979@umich.edu>
References: <1696396609.119284.1394040541217.JavaMail.zimbra@xes-inc.com>
	<260588931.122771.1394041524167.JavaMail.zimbra@xes-inc.com>
	<20140305201149.GA16212@umich.edu>
	<1106484945.149062.1394052088011.JavaMail.zimbra@xes-inc.com>
	<20140305211124.GA16979@umich.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/t7sWon8/_f.pDGKUX6arBjK"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/t7sWon8/_f.pDGKUX6arBjK
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 5 Mar 2014 16:11:24 -0500 Jim Rees <rees@umich.edu> wrote:

> Andrew Martin wrote:
>=20
>   Isn't intr/nointr deprecated (since kernel 2.6.25)?
>=20
> It isn't so much that it's deprecated as that it's now the default (except
> that only SIGKILL will work).

Not quite correct.  Any signal will work providing its behaviour is to kill
the process.  So SIGKILL will always work, and SIGTERM SIGINT SIGQUIT etc
will work providing that aren't caught or ignored by the process.

NeilBrown


> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--Sig_/t7sWon8/_f.pDGKUX6arBjK
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUxfs3jnsnt1WYoG5AQIhfA//Z+s+s0swkWg7jpv4bI9Y6vqiXXLsD6J6
uKCUDGBmuI4pBz5n0S6QccxCn8iahzEhyHn6qzZJU/OdulmBkEPdR3ljMFIt7LkB
T/q39Z6vnxjuyM7sAMlp1BtZMFm8KIgaMDy/eYNg1NZrQCZooeS5+UeP3bs/SJU+
oF/6J7OBbAKMx5gwOiJxkxmiTB1mqpFN0b/wuiF/pccwC65iNIgYD1Y7A66WheVA
bw8iASzC8hO8tDbx+lQrRf9jroRvZhgh0CJ8ZLusEjrtGzWmbwJ4gR4N79hqterR
40Ev1veNJ3LUCcPPW6E4a4GVMoPZhe06Ld2gM/aCNxwlLjyh82oliIkNiMIlf84+
J0OOsiU6YdSMKl+Y7jEKqum16W9ojSwS6sOHD4tLXpsuAEMIvpjwrSah/cRP7fjQ
QUix6OzVCjHCgC7jrjNRdOmJFSHx4m2mzmtRRKKm22G2Ok+YGAig6PPrEXA9/qmM
zVg66UgR/p/3PefkJ7/P/b2n67m3eUX8nHM6Qk+HBgv5W0p9B8SWM5FEJXgZT4VT
Xm7aBublGNlQGGfNwrtIqnqqz54JZbE8hYB/sFHyw0iWdq7IB0pX7ReVLCK77ZbB
1du3zU/vExcOLbxCCeVbyvycWJaYRFjpVfFXjrB/ZNGItEf24MKGfdFgE8mBhkVC
A+807hpdslY=
=MizO
-----END PGP SIGNATURE-----

--Sig_/t7sWon8/_f.pDGKUX6arBjK--
