Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail2.candelatech.com ([208.74.158.173]:39653 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752050AbaHMVWv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Aug 2014 17:22:51 -0400
Message-ID: <53EBD729.2020601@candelatech.com>
Date: Wed, 13 Aug 2014 14:22:49 -0700
From: Ben Greear <greearb@candelatech.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Killing process in D state on mount to dead NFS server.
References: <53DA8443.407@candelatech.com> <20140801064217.01852788@notabene.brown> <53DAB307.2000206@candelatech.com> <53EB876A.4090705@candelatech.com> <20140814071827.702b68e4@notabene.brown>
In-Reply-To: <20140814071827.702b68e4@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 08/13/2014 02:18 PM, NeilBrown wrote:
> On Wed, 13 Aug 2014 08:42:34 -0700 Ben Greear <greearb@candelatech.com> wrote:
> 
> Hello!
> 
> Did you get a chance to look at the stacks below?
> 
>> Yes I did, and I replied on Date: Fri, 1 Aug 2014 07:50:53 +1000

Hmm, I don't seem to have received that email (or I
managed to lose it quite thoroughly), but no worries.

>> The problem is that "fsync" and related functions are not killable. I think it is generally agreed that this is a bug, and that a fix would probably be
>> accepted. I started working on one the other day but haven't got very hard yet (lots of other things to work on).

Ok, thanks for the effort so far, and if you do get a patch cooked up,
I will be happy to test it.

Thanks,
Ben

- -- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQEcBAEBAgAGBQJT69cpAAoJELbHqkYeJT4OL34H/jxncIyX5sD9zm1DmiAJZA/g
nOpyk2603aMMj3qH91svxv8FCwoXpqnyV77vWUSKInkw+E1sWRsxuAZoKbxNjN4U
yCpfUlFc1IrDPSVV0Ax7oFs/DbOJRLrtrh3BW/0zBVZfw3RRYKEtR3LGAKtt+VNI
5RiwqFes/6tJXj6h8vF4WYBJ31J31mqWYh4GcJ2B2w3lYRX4CnTfAuJ75KRfTX3k
LESaS2w+7B9Ta42Xl9QU6SWsisdxEhYA0R5TbAl1MICjU7RvmLEyeKcuG3/DpPjJ
TjYoLR5SBcNqCBKab+L+j8jFPta8pE9LR/WWP0PfC/NWgw7+dy2VUFF2se7wSeY=
=GsQw
-----END PGP SIGNATURE-----
