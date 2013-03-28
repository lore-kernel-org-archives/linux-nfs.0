Return-Path: linux-nfs-owner@vger.kernel.org
Received: from li9-11.members.linode.com ([67.18.176.11]:56773 "EHLO
	imap.thunk.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756495Ab3C1Ozq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Mar 2013 10:55:46 -0400
Date: Thu, 28 Mar 2013 10:07:44 -0400
From: "Theodore Ts'o" <tytso@mit.edu>
To: Eric Sandeen <sandeen@redhat.com>
Cc: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
        Anand Avati <anand.avati@gmail.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        linux-ext4@vger.kernel.org, gluster-devel@nongnu.org
Subject: Re: [Gluster-devel] regressions due to 64-bit ext4 directory cookies
Message-ID: <20130328140744.GA4989@thunk.org>
References: <CAFboF2wXvP+vttiff8iRE9rAgvV8UWGbFprgVp8p7kE43TU=PA@mail.gmail.com>
 <20130213222052.GD5938@thunk.org>
 <20130213224141.GU14195@fieldses.org>
 <20130213224720.GE5938@thunk.org>
 <CAFboF2z1akN_edrY_fT915xfehfHGioA2M=PSHv0Fp3rD-5v5A@mail.gmail.com>
 <20130213230511.GW14195@fieldses.org>
 <20130213234430.GF5938@thunk.org>
 <CAFboF2zS+YAa0uUxMFUAbqgPh3Kb4xZu40WUjLyGn8qPoP+Oyw@mail.gmail.com>
 <5151BD5F.30607@itwm.fraunhofer.de>
 <5151C33E.2070008@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5151C33E.2070008@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 26, 2013 at 10:48:14AM -0500, Eric Sandeen wrote:
> > We don't have reached a conclusion so far, do we? What about the
> > ioctl approach, but a bit differently? Would it work to specify the
> > allowed upper bits for ext4 (for example 16 additional bit) and the
> > remaining part for gluster? One of the mails had the calculation
> > formula:
> 
> I did throw together an ioctl patch last week, but I think Anand has a new
> approach he's trying out which won't require ext4 code changes.  I'll let
> him reply when he has a moment.  :)

Any update about whether Gluster can address this without needing the
ioctl patch?  Or should we push the ioctl patch into ext4 for the next
merge window?

Thanks,

						- Ted
