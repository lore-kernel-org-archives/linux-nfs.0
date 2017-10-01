Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:58255 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750981AbdJAWBg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 1 Oct 2017 18:01:36 -0400
Date: Mon, 2 Oct 2017 09:01:31 +1100
From: "Tobin C. Harding" <me@tobin.cc>
To: =?iso-8859-1?B?Suly6W15?= Lefaure <jeremy.lefaure@lse.epita.fr>
Cc: alsa-devel@alsa-project.org, nouveau@lists.freedesktop.org,
        dri-devel@lists.freedesktop.org, dm-devel@redhat.com,
        brcm80211-dev-list@cypress.com, devel@driverdev.osuosl.org,
        linux-scsi@vger.kernel.org, linux-rdma@vger.kernel.org,
        amd-gfx@lists.freedesktop.org,
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
Message-ID: <20171001220131.GA11812@eros>
References: <20171001193101.8898-1-jeremy.lefaure@lse.epita.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <20171001193101.8898-1-jeremy.lefaure@lse.epita.fr>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Oct 01, 2017 at 03:30:38PM -0400, Jérémy Lefaure wrote:
> Hi everyone,
> Using ARRAY_SIZE improves the code readability. I used coccinelle (I
> made a change to the array_size.cocci file [1]) to find several places
> where ARRAY_SIZE could be used instead of other macros or sizeof
> division.
> 
> I tried to divide the changes into a patch per subsystem (excepted for
> staging). If one of the patch should be split into several patches, let
> me know.
> 
> In order to reduce the size of the To: and Cc: lines, each patch of the
> series is sent only to the maintainers and lists concerned by the patch.
> This cover letter is sent to every list concerned by this series.

Why don't you just send individual patches for each subsystem? I'm not a maintainer but I don't see
how any one person is going to be able to apply this whole series, it is making it hard for
maintainers if they have to pick patches out from among the series (if indeed any will bother
doing that).

I get that this will be more work for you but AFAIK we are optimizing for maintainers.

Good luck,
Tobin.
