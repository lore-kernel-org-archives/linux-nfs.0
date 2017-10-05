Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:58368 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751286AbdJER5P (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 5 Oct 2017 13:57:15 -0400
Date: Thu, 5 Oct 2017 13:57:15 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: =?utf-8?B?SsOpcsOpbXk=?= Lefaure <jeremy.lefaure@lse.epita.fr>
Cc: Greg KH <greg@kroah.com>, "Tobin C. Harding" <me@tobin.cc>,
        alsa-devel@alsa-project.org, nouveau@lists.freedesktop.org,
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
        linux-kernel@vger.kernel.org, linux-integrity@vger.kernel.org,
        jlayton@redhat.com
Subject: Re: [PATCH 00/18] use ARRAY_SIZE macro
Message-ID: <20171005175715.GA19093@fieldses.org>
References: <20171001193101.8898-1-jeremy.lefaure@lse.epita.fr>
 <20171001220131.GA11812@eros>
 <20171001205220.10b78086@blatinox-laptop.localdomain>
 <20171002053554.GA28743@kroah.com>
 <20171002192224.GD1903@fieldses.org>
 <20171002213312.3f904290@blatinox-laptop.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20171002213312.3f904290@blatinox-laptop.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 02, 2017 at 09:33:12PM -0400, Jérémy Lefaure wrote:
> On Mon, 2 Oct 2017 15:22:24 -0400
> bfields@fieldses.org (J. Bruce Fields) wrote:
> 
> > Mainly I'd just like to know which you're asking for.  Do you want me to
> > apply this, or to ACK it so someone else can?  If it's sent as a series
> > I tend to assume the latter.
> > 
> > But in this case I'm assuming it's the former, so I'll pick up the nfsd
> > one....
> Could you to apply the NFSD patch ("nfsd: use ARRAY_SIZE") with the
> Reviewed-by: Jeff Layton <jlayton@redhat.com>) tag please ?
> 
> This patch is an individual patch and it should not have been sent in a
> series (sorry about that).

Applying for 4.15, thanks.--b.
