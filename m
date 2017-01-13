Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:48112 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751036AbdAMQUX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Jan 2017 11:20:23 -0500
Date: Fri, 13 Jan 2017 16:19:52 +0000
From: Russell King - ARM Linux <linux@armlinux.org.uk>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Cc: David Howells <dhowells@redhat.com>, arnd@arndb.de,
        linux-mips@linux-mips.org, linux-m68k@vger.kernel.org,
        linux-ia64@vger.kernel.org, linux-doc@vger.kernel.org,
        alsa-devel@alsa-project.org, dri-devel@lists.freedesktop.org,
        linux-mtd@lists.infradead.org, sparclinux@vger.kernel.org,
        linux-arch@vger.kernel.org, linux-s390@vger.kernel.org,
        linux-am33-list@redhat.com, linux-c6x-dev@linux-c6x.org,
        linux-rdma@vger.kernel.org, linux-hexagon@vger.kernel.org,
        linux-sh@vger.kernel.org, coreteam@netfilter.org,
        fcoe-devel@open-fcoe.org, xen-devel@lists.xenproject.org,
        linux-snps-arc@lists.infradead.org, linux-media@vger.kernel.org,
        uclinux-h8-devel@lists.sourceforge.jp, linux-xtensa@linux-xtensa.org,
        linux-kbuild@vger.kernel.org,
        adi-buildroot-devel@lists.sourceforge.net, linux-raid@vger.kernel.org,
        openrisc@lists.librecores.org, linux-fbdev@vger.kernel.org,
        linux-metag@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-nfs@vger.kernel.org, linux-parisc@vger.kernel.org,
        linux-cris-kernel@axis.com, linux-mmc@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-spi@vger.kernel.org,
        netfilter-devel@vger.kernel.org, linux-alpha@vger.kernel.org,
        nio2-dev@lists.rocketboards.org, linuxppc-dev@lists.ozlabs.org
Subject: Re: [PATCH v3 1/8] arm: put types.h in uapi
Message-ID: <20170113161951.GT14217@n2100.armlinux.org.uk>
References: <1484304406-10820-2-git-send-email-nicolas.dichtel@6wind.com>
 <3131144.4Ej3KFWRbz@wuerfel>
 <1484304406-10820-1-git-send-email-nicolas.dichtel@6wind.com>
 <25063.1484321803@warthog.procyon.org.uk>
 <4633e475-47f2-5627-81a9-a1747dfddbc0@6wind.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <4633e475-47f2-5627-81a9-a1747dfddbc0@6wind.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 13, 2017 at 05:01:01PM +0100, Nicolas Dichtel wrote:
> Please, do not remove the email subject when you reply. I restore it to
> ease the thread follow-up.

I mentioned it to David, and he says it's because the long list of
recipients is breaking his mailer.  I've already posed the question
about whether that's exploitable!

> Le 13/01/2017 à 16:36, David Howells a écrit :
> > Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:
> > 
> >> This header file is exported, thus move it to uapi.
> > 
> > Exported how?
> 
> It is listed in include/uapi/asm-generic/Kbuild.asm, which is included by
> arch/arm/include/uapi/asm/Kbuild.

We really should not be installing non-uapi header files to userland
under _any_ circumstance - this to me sounds like a bug in kbuild.

The assumption is that headers outside of uapi directories are not
part of the user visible API, and so can be freely modified - which
in the presence of this bug is untrue.

However, as it's happening, and this header has been there since 2013
(commit 09096f6a0ee2 - "ARM: 7822/1: add workaround for ambiguous C99
stdint.h types") it's now well and truely part of the user API whether
we intended it to be or not, so your patch looks to me like the correct
thing to do.

I think it needs further evaluation to make sure kbuild isn't going to
do something else silly, like subsitute include/asm-generic/types.h for
the now missing arch/arm/include/asm/types.h

I wonder how many more headers are unintentionally exported.

... what a mess. :(

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
