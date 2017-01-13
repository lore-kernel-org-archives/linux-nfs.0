Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48540 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751801AbdAMPpg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 13 Jan 2017 10:45:36 -0500
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1484304406-10820-5-git-send-email-nicolas.dichtel@6wind.com>
References: <1484304406-10820-5-git-send-email-nicolas.dichtel@6wind.com> <3131144.4Ej3KFWRbz@wuerfel> <1484304406-10820-1-git-send-email-nicolas.dichtel@6wind.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Cc: dhowells@redhat.com, arnd@arndb.de, linux-kbuild@vger.kernel.org,
        linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org,
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
        linux@armlinux.org.uk
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Fri, 13 Jan 2017 15:43:49 +0000
Message-ID: <25483.1484322229@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -header-y += msr-index.h

I see it on my desktop as /usr/include/asm/msr-index.h and it's been there at
least four years - and as such it's part of the UAPI.  I don't think you can
remove it unless you can guarantee there are no userspace users.

David
