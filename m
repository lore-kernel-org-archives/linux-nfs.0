Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from afk.unpythonic.net ([138.68.55.246]:41379 "EHLO
        afk.unpythonic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750779AbdAMBaY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Jan 2017 20:30:24 -0500
Date: Thu, 12 Jan 2017 19:04:27 -0600
From: Jeff Epler <jepler@unpythonic.net>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Cc: Jan Engelhardt <jengelh@inai.de>,
        Christoph Hellwig <hch@infradead.org>, arnd@arndb.de, mmarek@suse.com,
        linux-kbuild@vger.kernel.org, linux-doc@vger.kernel.org,
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
        airlied@linux.ie, davem@davemloft.net
Subject: Re: [PATCH v2 7/7] uapi: export all headers under uapi directories
Message-ID: <20170113010427.GA22650@unpythonic.net>
References: <bf83da6b-01ef-bf44-b3e1-ca6fc5636818@6wind.com>
 <1483695839-18660-1-git-send-email-nicolas.dichtel@6wind.com>
 <1483695839-18660-8-git-send-email-nicolas.dichtel@6wind.com>
 <20170109125638.GA15506@infradead.org>
 <464a1323-4450-e563-ff59-9e6d57b75959@6wind.com>
 <alpine.LSU.2.20.1701121727180.19188@erq.vanv.qr>
 <9d68af8a-a609-d7b1-58a9-f1155313b077@6wind.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <9d68af8a-a609-d7b1-58a9-f1155313b077@6wind.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 12, 2017 at 05:32:09PM +0100, Nicolas Dichtel wrote:
> What I was trying to say is that I export those directories like other are.
> Removing those files is not related to that series.

Perhaps the correct solution is to only copy files matching "*.h" to
reduce the risk of copying files incidentally created by kbuild but
which shouldn't be installed as uapi headers.

jeff
