From: Timo Sirainen <tss@iki.fi>
Subject: Re: NFS server waking up sleeping disks
Date: Sun, 9 Mar 2008 05:11:20 +0200
Message-ID: <CFB019DD-6BDA-4007-B4AA-3E06C58196FD@iki.fi>
References: <1204969522.11220.680.camel@hurina>	 <47D29BC2.9000806@foo-lounge.de> <1205018864.11220.689.camel@hurina> <47D35249.7020000@foo-lounge.de>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: multipart/signed; protocol="application/pgp-signature"; micalg=pgp-sha1; boundary="Apple-Mail-4--908186495"
Cc: linux-nfs@vger.kernel.org
To: Timo Reimann <mailinglist-d4LLFNs4DFRA7UZ8SB9NFg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dovecot.org ([82.118.211.50]:51248 "EHLO dovecot.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751085AbYCIDLW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 8 Mar 2008 22:11:22 -0500
In-Reply-To: <47D35249.7020000-d4LLFNs4DFRA7UZ8SB9NFg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--Apple-Mail-4--908186495
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit

On Mar 9, 2008, at 4:58 AM, Timo Reimann wrote:

>>> However, there is no `ls' or similar call required to wake up my  
>>> disk.
>>> It just happens.
>>
>> Thanks, mountd is indeed the problem:
>>
>> I'll go figure out why it's doing this.
>
> If you find a solution prior to the other guys who offered their  
> help to
> me, please let us (especially me :) ) know.

Well, after half an hour of looking at mountd and libblk code and  
trying to figure out why I can't seem to find the code for what I see  
in the strace, I finally found out the mountd sources were newer than  
what I was using and this issue was already fixed (Debian unstable):

   * 10-no-flush-blkid-cache.diff: New patch from Theodore Ts'o, removes
     unneccessary flushing of the blkid cache, leading to lots of  
spurious
     DM_* ioctls. (Closes: #431940)

This appears to fix my problem, although it'll probably takes a few  
days until I'm sure. This is the second time already when I've wasted  
a lot of time trying to figure out a problem, only to find out that  
dist-upgrade would have solved it. Have to remember to do that the  
next time. :)


--Apple-Mail-4--908186495
content-type: application/pgp-signature; x-mac-type=70674453;
	name=PGP.sig
content-description: This is a digitally signed message part
content-disposition: inline; filename=PGP.sig
content-transfer-encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.8 (Darwin)

iEYEARECAAYFAkfTVVgACgkQyUhSUUBVislhzgCeLC4gswQCFoT2APEj5o7aypgt
pQsAoIzI+KXyZxZ9/8mX5MJCxf7XBBkP
=Epi8
-----END PGP SIGNATURE-----

--Apple-Mail-4--908186495--
