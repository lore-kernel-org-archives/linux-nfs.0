Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:33592 "EHLO
        mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750873AbdAMQCC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Jan 2017 11:02:02 -0500
Received: by mail-lf0-f50.google.com with SMTP id k86so41055441lfi.0
        for <linux-nfs@vger.kernel.org>; Fri, 13 Jan 2017 08:01:09 -0800 (PST)
Reply-To: nicolas.dichtel@6wind.com
Subject: Re: [PATCH v3 1/8] arm: put types.h in uapi
References: <1484304406-10820-2-git-send-email-nicolas.dichtel@6wind.com>
 <3131144.4Ej3KFWRbz@wuerfel>
 <1484304406-10820-1-git-send-email-nicolas.dichtel@6wind.com>
 <25063.1484321803@warthog.procyon.org.uk>
To: David Howells <dhowells@redhat.com>
Cc: arnd@arndb.de, linux-mips@linux-mips.org,
        linux-m68k@vger.kernel.org, linux-ia64@vger.kernel.org,
        linux-doc@vger.kernel.org, alsa-devel@alsa-project.org,
        dri-devel@lists.freedesktop.org, linux-mtd@lists.infradead.org,
        sparclinux@vger.kernel.org, linux-arch@vger.kernel.org,
        linux-s390@vger.kernel.org, linux-am33-list@redhat.com,
        linux-c6x-dev@linux-c6x.org, linux-rdma@vger.kernel.org,
        linux-hexagon@vger.kernel.org, linux-sh@vger.kernel.org,
        linux@armlinux.org.uk, coreteam@netfilter.org,
        fcoe-devel@open-fcoe.org, xen-devel@lists.xenproject.org,
        linux-snps-arc@lists.infradead.org, linux-media@vger.kernel.org,
        uclinux-h8-devel@lists.sourceforge.jp,
        linux-xtensa@linux-xtensa.org, linux-kbuild@vger.kernel.org,
        adi-buildroot-devel@lists.sourceforge.net,
        linux-raid@vger.kernel.org, openrisc@lists.librecores.org,
        linux-fbdev@vger.kernel.org, linux-metag@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-nfs@vger.kernel.org,
        linux-parisc@vger.kernel.org, linux-cris-kernel@axis.com,
        linux-mmc@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-spi@vger.kernel.org, netfilter-devel@vger.kernel.org,
        linux-alpha@vger.kernel.org, nio2-dev@lists.rocketboards.org,
        linuxppc-dev@lists.ozlabs.org
From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Message-ID: <4633e475-47f2-5627-81a9-a1747dfddbc0@6wind.com>
Date: Fri, 13 Jan 2017 17:01:01 +0100
MIME-Version: 1.0
In-Reply-To: <25063.1484321803@warthog.procyon.org.uk>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please, do not remove the email subject when you reply. I restore it to ease the
thread follow-up.

Le 13/01/2017 à 16:36, David Howells a écrit :
> Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:
> 
>> This header file is exported, thus move it to uapi.
> 
> Exported how?
It is listed in include/uapi/asm-generic/Kbuild.asm, which is included by
arch/arm/include/uapi/asm/Kbuild.

You can also have a look at patch #5 to see why it was exported even if it was
not in an uapi directory.

Regards,
Nicolas
