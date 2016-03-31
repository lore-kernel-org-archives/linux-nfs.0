Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:40660 "EHLO
	prv3-mh.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750978AbcCaFH3 (ORCPT
	<rfc822;groupwise-linux-nfs@vger.kernel.org:0:0>);
	Thu, 31 Mar 2016 01:07:29 -0400
From: NeilBrown <nfbrown@novell.com>
To: Christian Robottom Reis <kiko@acm.org>,
        NFS List <linux-nfs@vger.kernel.org>
Date: Thu, 31 Mar 2016 16:07:15 +1100
Subject: Re: Finding and breaking client locks
In-Reply-To: <20160322005813.GA3378@anthem.async.com.br>
References: <20160321143914.GA6397@anthem.async.com.br> <20160322005813.GA3378@anthem.async.com.br>
Message-ID: <87io03s0ak.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Tue, Mar 22 2016, Christian Robottom Reis wrote:

> On Mon, Mar 21, 2016 at 11:39:14AM -0300, Christian Robottom Reis wrote:
>> indeed does not return any information pertaining NFS client locks, and
>> I'm not clear whether /proc/locks (on the server side obviously) does or
>> not.
>
> Somewhat OT, but I find it a PITA that /proc/locks gives inode numbers
> that then need to be looked up individually. I have often been surprised
> no tool exists to parse that and give you back a report of filenames, so
> I just put together a small tool that just offloads the work to debugfs.
>
> I've attached it in case others might find it useful.

Nice idea, though it only works with extXfs - better than nothing
though.

It would be really easy to do this in the kernel.
I would be very much in favour of a /proc/locks-extended (or whatever)
that provides the same information as /proc/locks, but in a format
which includes full path name, process name, and - for nfs locks -
client name etc.

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJW/LCDAAoJEDnsnt1WYoG5g38QALkMe9GFKOJh9szGD3LpZVod
0WSyu+TdZvHUnaLh0+2jx5GjVwR7LZuumKR5cHud+J02Qf54fChHS0NlFmQ05dp8
iMg+hryEN4wnSm/8gKgYLFhflMDuz41LOWrldDqqrGmfNjyKpdzEx+nzxJ7UCmmw
7cB/L8e+DJQbIa4Tvshz5PQ4vEVbxARnjQ+I2C5ycBcoL5uiexSgMbsKsLzo+zX1
XV+EUYE/HacUhE5NLEG4yUW8gCn0VrHbDdttwDxarfadsW6TEE6vdD5d2qQns//i
XHPpGUvwcEr3qr7NPztGQShYjEI9aXDbyp6uuflZlHQmcbEkZM2vi08CWaLAHAEk
Joi0gzc9Rex13+9gxiJjTywR+a0da6kd/Yin7R3FLyEg6czypS/hJpFMb+80MKzM
4H8kiNFZM8wrc2IuVuMSzUhjwMMS/nPH7qBswae0dLyR7F/CWe8hpiesYe19hf0G
jv4Qz7GfU5Fevw8ITY/4oNiPHjNdNjcpodt3GTKYfTtrklMht9HJ/KjUJikvfUBF
D9Yr6HQanSjU6Ni4sru3I9AA61V2eRZgatBjU7R4PF2g6hfMOnO2fDA51PyL5A6z
CAsrfPXrcxfcPN8QbKJO/AHYnY0XDxJypDAN7u4CJbZbkidrcTltWwyaNbdcWh6H
VFJ4YBMA7hV9dAhwYXB4
=FDgH
-----END PGP SIGNATURE-----
--=-=-=--
