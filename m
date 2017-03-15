Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([148.251.95.138]:35632 "EHLO
        cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753065AbdCOJwX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Mar 2017 05:52:23 -0400
Received: from localhost.localdomain ([127.0.0.1]:57312 "EHLO linux-mips.org"
        rhost-flags-OK-OK-OK-FAIL) by eddie.linux-mips.org with ESMTP
        id S23991232AbdCOJwVMZqtG (ORCPT <rfc822;linux-nfs@vger.kernel.org>
        + 1 other); Wed, 15 Mar 2017 10:52:21 +0100
Date: Wed, 15 Mar 2017 10:25:36 +0100
From: Ralf Baechle <ralf@linux-mips.org>
To: James Hogan <james.hogan@imgtec.com>
Cc: Matt Turner <mattst88@gmail.com>,
        "linux-mips@linux-mips.org" <linux-mips@linux-mips.org>,
        linux-nfs@vger.kernel.org, Manuel Lauss <manuel.lauss@gmail.com>,
        LKML <linux-kernel@vger.kernel.org>
Subject: Re: NFS corruption, fixed by echo 1 > /proc/sys/vm/drop_caches --
 next debugging steps?
Message-ID: <20170315092536.GC22089@linux-mips.org>
References: <CAEdQ38HcOgAT6wJWWKY3P0hzYwkBGSQkRSQ2a=eaGmD6c6rwXA@mail.gmail.com>
 <20170313094757.GI2878@jhogan-linux.le.imgtec.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170313094757.GI2878@jhogan-linux.le.imgtec.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 13, 2017 at 09:47:57AM +0000, James Hogan wrote:

> > 
> > Note that the corruption is different across reboots, both in the size
> > of the corruption and the location. I saw 1900~ and 1400~ byte
> > sequences corrupted on separate occasions, which don't correspond to
> > the system's 16kB page size.
> > 
> > I've tested kernels from v3.19 to 4.11-rc1+ (master branch from
> > today). All exhibit this behavior with differing frequencies. Earlier
> > kernels seem to reproduce the issue less often, while more recent
> > kernels reliably exhibit the problem every boot.
> > 
> > How can I further debug this?
> 
> It smells a bit like a DMA / caching issue.
> 
> Can you provide a full kernel log. That might provide some information
> about caching that might be relevant (e.g. does dcache have aliases?).

The architecture of the BCM1250 SOC used for the BCM91250 boards are
fully coherent, S-cache and D-cache are physically indexed and tagged.
Only the VIVT (plus the usual ASID tagging) I-cache leaves space for
software to screw up cache management but that shouldn't matter for this
case, so I suggest to start looking into this from the NFS side.

  Ralf
