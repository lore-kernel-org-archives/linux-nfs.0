Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:34862 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936099AbdAIMBh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Jan 2017 07:01:37 -0500
Date: Mon, 9 Jan 2017 12:01:08 +0000
From: Russell King - ARM Linux <linux@armlinux.org.uk>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Cc: arnd@arndb.de, linux-mips@linux-mips.org, alsa-devel@alsa-project.org,
        linux-ia64@vger.kernel.org, linux-doc@vger.kernel.org,
        airlied@linux.ie, linux-fbdev@vger.kernel.org,
        dri-devel@lists.freedesktop.org, linux-mtd@lists.infradead.org,
        sparclinux@vger.kernel.org, linux-arch@vger.kernel.org,
        linux-s390@vger.kernel.org, linux-am33-list@redhat.com,
        linux-c6x-dev@linux-c6x.org, linux-rdma@vger.kernel.org,
        linux-hexagon@vger.kernel.org, linux-sh@vger.kernel.org,
        coreteam@netfilter.org, fcoe-devel@open-fcoe.org,
        xen-devel@lists.xenproject.org, linux-snps-arc@lists.infradead.org,
        linux-media@vger.kernel.org, uclinux-h8-devel@lists.sourceforge.jp,
        linux-xtensa@linux-xtensa.org, linux-kbuild@vger.kernel.org,
        adi-buildroot-devel@lists.sourceforge.net, linux-raid@vger.kernel.org,
        linux-m68k@vger.kernel.org, openrisc@lists.librecores.org,
        linux-metag@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-nfs@vger.kernel.org, linux-parisc@vger.kernel.org,
        linux-cris-kernel@axis.com, netdev@vger.kernel.org,
        linux-mmc@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-spi@vger.kernel.org, mmarek@suse.com,
        netfilter-devel@vger.kernel.org, linux-alpha@vger.kernel.org,
        nios2-dev@lists.rocketboards.org, linuxppc-dev@lists.ozlabs.org,
        davem@davemloft.net
Subject: Re: [PATCH v2 7/7] uapi: export all headers under uapi directories
Message-ID: <20170109120107.GW14217@n2100.armlinux.org.uk>
References: <bf83da6b-01ef-bf44-b3e1-ca6fc5636818@6wind.com>
 <1483695839-18660-1-git-send-email-nicolas.dichtel@6wind.com>
 <1483695839-18660-8-git-send-email-nicolas.dichtel@6wind.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1483695839-18660-8-git-send-email-nicolas.dichtel@6wind.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 06, 2017 at 10:43:59AM +0100, Nicolas Dichtel wrote:
> diff --git a/arch/arm/include/uapi/asm/Kbuild b/arch/arm/include/uapi/asm/Kbuild
> index 46a76cd6acb6..607f702c2d62 100644
> --- a/arch/arm/include/uapi/asm/Kbuild
> +++ b/arch/arm/include/uapi/asm/Kbuild
> @@ -1,23 +1,6 @@
>  # UAPI Header export list
>  include include/uapi/asm-generic/Kbuild.asm
>  
> -header-y += auxvec.h
> -header-y += byteorder.h
> -header-y += fcntl.h
> -header-y += hwcap.h
> -header-y += ioctls.h
> -header-y += kvm_para.h
> -header-y += mman.h
> -header-y += perf_regs.h
> -header-y += posix_types.h
> -header-y += ptrace.h
> -header-y += setup.h
> -header-y += sigcontext.h
> -header-y += signal.h
> -header-y += stat.h
> -header-y += statfs.h
> -header-y += swab.h
> -header-y += unistd.h
>  genhdr-y += unistd-common.h
>  genhdr-y += unistd-oabi.h
>  genhdr-y += unistd-eabi.h

Acked-by: Russell King <rmk+kernel@armlinux.org.uk>

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
