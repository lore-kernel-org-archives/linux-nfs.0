Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55459 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754523Ab3C1Sb6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Mar 2013 14:31:58 -0400
Date: Thu, 28 Mar 2013 14:31:53 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Anand Avati <anand.avati@gmail.com>
Cc: Zach Brown <zab@redhat.com>, "Theodore Ts'o" <tytso@mit.edu>,
        Eric Sandeen <sandeen@redhat.com>,
        Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
        linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        gluster-devel@nongnu.org
Subject: Re: [Gluster-devel] regressions due to 64-bit ext4 directory cookies
Message-ID: <20130328183153.GG7080@fieldses.org>
References: <20130213224720.GE5938@thunk.org>
 <CAFboF2z1akN_edrY_fT915xfehfHGioA2M=PSHv0Fp3rD-5v5A@mail.gmail.com>
 <20130213230511.GW14195@fieldses.org>
 <20130213234430.GF5938@thunk.org>
 <CAFboF2zS+YAa0uUxMFUAbqgPh3Kb4xZu40WUjLyGn8qPoP+Oyw@mail.gmail.com>
 <5151BD5F.30607@itwm.fraunhofer.de>
 <5151C33E.2070008@redhat.com>
 <20130328140744.GA4989@thunk.org>
 <20130328175205.GD16651@lenny.home.zabbo.net>
 <CAFboF2ztc06G00z8ga35NrxgnT2YgBiDECgU_9kvVA_Go1_Bww@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAFboF2ztc06G00z8ga35NrxgnT2YgBiDECgU_9kvVA_Go1_Bww@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 28, 2013 at 11:05:41AM -0700, Anand Avati wrote:
> On Thu, Mar 28, 2013 at 10:52 AM, Zach Brown <zab@redhat.com> wrote:
> 
> > On Thu, Mar 28, 2013 at 10:07:44AM -0400, Theodore Ts'o wrote:
> > > On Tue, Mar 26, 2013 at 10:48:14AM -0500, Eric Sandeen wrote:
> > > > > We don't have reached a conclusion so far, do we? What about the
> > > > > ioctl approach, but a bit differently? Would it work to specify the
> > > > > allowed upper bits for ext4 (for example 16 additional bit) and the
> > > > > remaining part for gluster? One of the mails had the calculation
> > > > > formula:
> > > >
> > > > I did throw together an ioctl patch last week, but I think Anand has a
> > new
> > > > approach he's trying out which won't require ext4 code changes.  I'll
> > let
> > > > him reply when he has a moment.  :)
> > >
> > > Any update about whether Gluster can address this without needing the
> > > ioctl patch?  Or should we push the ioctl patch into ext4 for the next
> > > merge window?
> >
> > They're testing a work-around:
> >
> >   http://review.gluster.org/#change,4711
> >
> > I'm not sure if they've decided that they're going to go with it, or
> > not.
> >
> 
> Jeff reported that the approach did not work in his testing. I haven't had
> a chance to look into the failure yet. Independent of the fix, it would
> certainly be good have the ioctl() support

The one advantage of your scheme is that it keeps more of the hash bits;
the chance of 31-bit cookie collisions is much higher.

> Samba could use it too, if it wanted.

It'd be useful to understand their situation.

--b.
