Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:35323 "EHLO
        mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752100AbdAMQIt (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Jan 2017 11:08:49 -0500
Received: by mail-wm0-f42.google.com with SMTP id r126so71510508wmr.0
        for <linux-nfs@vger.kernel.org>; Fri, 13 Jan 2017 08:08:49 -0800 (PST)
Reply-To: nicolas.dichtel@6wind.com
Subject: Re: [PATCH v3 4/8] x86: stop exporting msr-index.h to userland
References: <1484304406-10820-5-git-send-email-nicolas.dichtel@6wind.com>
 <3131144.4Ej3KFWRbz@wuerfel>
 <1484304406-10820-1-git-send-email-nicolas.dichtel@6wind.com>
 <25483.1484322229@warthog.procyon.org.uk>
To: David Howells <dhowells@redhat.com>
Cc: arnd@arndb.de, linux-kbuild@vger.kernel.org, linux-doc@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org,
        linux-snps-arc@lists.infradead.org,
        linux-arm-kernel@lists.infradead.org,
        adi-buildroot-devel@lists.sourceforge.net, linux-c6x-dev@linux-c6x.org,
        linux-cris-kernel@axis.com, uclinux-h8-devel@lists.sourceforge.jp,
        linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org,
        linux-m68k@vger.kernel.org, linux-metag@vger.kernel.org,
        linux-mips@linux-mips.org, linux-am33-list@redhat.com,
        nios2-dev@lists.rocketboards.org, openrisc@lists.librecores.org,
        linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
        sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org,
        linux-arch@vger.kernel.org, dri-devel@lists.freedesktop.org,
        netdev@vger.kernel.org, linux-media@vger.kernel.org,
        linux-mmc@vger.kernel.org, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, linux-nfs@vger.kernel.org,
        linux-raid@vger.kernel.org, linux-spi@vger.kernel.org,
        linux-mtd@lists.infradead.org, linux-rdma@vger.kernel.org,
        fcoe-devel@open-fcoe.org, alsa-devel@alsa-project.org,
        linux-fbdev@vger.kernel.org, xen-devel@lists.xenproject.org,
        linux@armlinux.org.uk, Borislav Petkov <bp@alien8.de>
From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Message-ID: <dd826bc7-e1ef-be29-e0c3-692afb346036@6wind.com>
Date: Fri, 13 Jan 2017 17:08:34 +0100
MIME-Version: 1.0
In-Reply-To: <25483.1484322229@warthog.procyon.org.uk>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Le 13/01/2017 à 16:43, David Howells a écrit :
>> -header-y += msr-index.h
> 
> I see it on my desktop as /usr/include/asm/msr-index.h and it's been there at
> least four years - and as such it's part of the UAPI.  I don't think you can
> remove it unless you can guarantee there are no userspace users.
I keep it in the v2 of the series, but the maintainer, Borislav Petkov, asks me
to un-export it.

I will follow the maintainer decision.


Regards,
Nicolas
