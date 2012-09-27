Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-tx2.bigfish.com ([65.55.88.10]:6964 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753276Ab2I0SLk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Sep 2012 14:11:40 -0400
Date: Thu, 27 Sep 2012 19:56:23 +0200
From: Joerg Roedel <joerg.roedel@amd.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Joerg Roedel <joro@8bytes.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>
Subject: Re: kernel BUG at /data/lemmy/linux.trees.git/fs/nfs/idmap.c:681!
Message-ID: <20120927175623.GG10549@amd.com>
References: <20120807134156.GP1996@amd.com>
 <20120927145217.GA18962@8bytes.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA908FEF572@SACEXCMBX04-PRD.hq.netapp.com>
 <20120927153928.GB18962@8bytes.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA908FEF7A3@SACEXCMBX04-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA908FEF7A3@SACEXCMBX04-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 27, 2012 at 04:16:25PM +0000, Myklebust, Trond wrote:
> > Yes, it contains that commit. I was about to test plain v3.6-rc7 without
> > my patches (not nfs related, of cource) on-top, but unfortunatly the
> > disk with the root-fs died :-/
> > I am about to set up the box again and test plain -rc7.
> 
> Please do.

Okay, the box is running again and the bug does not reproduce anymore
with the new installation. Unfortunatly the old kernel configuration is
gone together with the previous version of the nfs-utils :-/ I'll try to
play around with the kernel config a little bit more and see if it
reproduces again.


	Joerg

-- 
AMD Operating System Research Center

Advanced Micro Devices GmbH Einsteinring 24 85609 Dornach
General Managers: Alberto Bozzo
Registration: Dornach, Landkr. Muenchen; Registerger. Muenchen, HRB Nr. 43632

