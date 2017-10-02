Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:52398 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751132AbdJBTWZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 2 Oct 2017 15:22:25 -0400
Date: Mon, 2 Oct 2017 15:22:24 -0400
To: Greg KH <greg@kroah.com>
Cc: =?utf-8?B?SsOpcsOpbXk=?= Lefaure <jeremy.lefaure@lse.epita.fr>,
        "Tobin C. Harding" <me@tobin.cc>, alsa-devel@alsa-project.org,
        nouveau@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
        dm-devel@redhat.com, brcm80211-dev-list@cypress.com,
        devel@driverdev.osuosl.org, linux-scsi@vger.kernel.org,
        linux-rdma@vger.kernel.org, amd-gfx@lists.freedesktop.org,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        linux-acpi@vger.kernel.org, linux-video@atrey.karlin.mff.cuni.cz,
        intel-wired-lan@lists.osuosl.org, linux-media@vger.kernel.org,
        intel-gfx@lists.freedesktop.org, ecryptfs@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-raid@vger.kernel.org,
        openipmi-developer@lists.sourceforge.net,
        intel-gvt-dev@lists.freedesktop.org, devel@acpica.org,
        brcm80211-dev-list.pdl@broadcom.com, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org, linux-wireless@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-integrity@vger.kernel.org
Subject: Re: [PATCH 00/18] use ARRAY_SIZE macro
Message-ID: <20171002192224.GD1903@fieldses.org>
References: <20171001193101.8898-1-jeremy.lefaure@lse.epita.fr>
 <20171001220131.GA11812@eros>
 <20171001205220.10b78086@blatinox-laptop.localdomain>
 <20171002053554.GA28743@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20171002053554.GA28743@kroah.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 02, 2017 at 07:35:54AM +0200, Greg KH wrote:
> On Sun, Oct 01, 2017 at 08:52:20PM -0400, Jérémy Lefaure wrote:
> > On Mon, 2 Oct 2017 09:01:31 +1100
> > "Tobin C. Harding" <me@tobin.cc> wrote:
> > 
> > > > In order to reduce the size of the To: and Cc: lines, each patch of the
> > > > series is sent only to the maintainers and lists concerned by the patch.
> > > > This cover letter is sent to every list concerned by this series.  
> > > 
> > > Why don't you just send individual patches for each subsystem? I'm not a maintainer but I don't see
> > > how any one person is going to be able to apply this whole series, it is making it hard for
> > > maintainers if they have to pick patches out from among the series (if indeed any will bother
> > > doing that).
> > Yeah, maybe it would have been better to send individual patches.
> > 
> > From my point of view it's a series because the patches are related (I
> > did a git format-patch from my local branch). But for the maintainers
> > point of view, they are individual patches.
> 
> And the maintainers view is what matters here, if you wish to get your
> patches reviewed and accepted...

Mainly I'd just like to know which you're asking for.  Do you want me to
apply this, or to ACK it so someone else can?  If it's sent as a series
I tend to assume the latter.

But in this case I'm assuming it's the former, so I'll pick up the nfsd
one....

--b.
