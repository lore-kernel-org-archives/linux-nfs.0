Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:5883 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751160Ab3C1ToC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Mar 2013 15:44:02 -0400
Message-ID: <51549D74.1060703@redhat.com>
Date: Thu, 28 Mar 2013 15:43:48 -0400
From: Jeff Darcy <jdarcy@redhat.com>
MIME-Version: 1.0
To: Anand Avati <anand.avati@gmail.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        Eric Sandeen <sandeen@redhat.com>, linux-nfs@vger.kernel.org,
        "Theodore Ts'o" <tytso@mit.edu>, Zach Brown <zab@redhat.com>,
        Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
        linux-ext4@vger.kernel.org, gluster-devel@nongnu.org
Subject: Re: [Gluster-devel] regressions due to 64-bit ext4 directory cookies
References: <20130213224720.GE5938@thunk.org> <CAFboF2z1akN_edrY_fT915xfehfHGioA2M=PSHv0Fp3rD-5v5A@mail.gmail.com> <20130213230511.GW14195@fieldses.org> <20130213234430.GF5938@thunk.org> <CAFboF2zS+YAa0uUxMFUAbqgPh3Kb4xZu40WUjLyGn8qPoP+Oyw@mail.gmail.com> <5151BD5F.30607@itwm.fraunhofer.de> <5151C33E.2070008@redhat.com> <20130328140744.GA4989@thunk.org> <20130328175205.GD16651@lenny.home.zabbo.net> <CAFboF2ztc06G00z8ga35NrxgnT2YgBiDECgU_9kvVA_Go1_Bww@mail.gmail.com> <20130328183153.GG7080@fieldses.org> <CAFboF2w49Lc0vM0SerbJfL9_RuSHgEU+y_Yk7F4pLxeiqu+KRg@mail.gmail.com>
In-Reply-To: <CAFboF2w49Lc0vM0SerbJfL9_RuSHgEU+y_Yk7F4pLxeiqu+KRg@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/28/2013 02:49 PM, Anand Avati wrote:
> Yes, it should, based on the theory of how ext4 was generating the
> 63bits. But Jeff's test finds that the experiment is not matching the
> theory.

FWIW, I was able to re-run my test in between stuff related to That
Other Problem.  What seems to be happening is that we read correctly
until just after d_off 0x4000000000000000, then we suddenly wrap around
- not to the very first d_off we saw, but to a pretty early one (e.g.
0x0041b6340689a32e).  This is all on a single brick, BTW, so it's pretty
easy to line up the back-end and front-end d_off values which match
perfectly up to this point.

I haven't had a chance to ponder what this all means and debug it
further.  Hopefully I'll be able to do so soon, but I figured I'd
mention it in case something about those numbers rang a bell.


