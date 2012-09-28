Return-Path: linux-nfs-owner@vger.kernel.org
Received: from tx2ehsobe002.messaging.microsoft.com ([65.55.88.12]:4974 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757247Ab2I1Nef (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Sep 2012 09:34:35 -0400
Date: Fri, 28 Sep 2012 15:34:24 +0200
From: Joerg Roedel <joerg.roedel@amd.com>
To: Bryan Schumaker <bjschuma@netapp.com>
CC: Joerg Roedel <joro@8bytes.org>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>
Subject: Re: kernel BUG at /data/lemmy/linux.trees.git/fs/nfs/idmap.c:681!
Message-ID: <20120928133424.GA4009@amd.com>
References: <20120807134156.GP1996@amd.com>
 <20120927145217.GA18962@8bytes.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA908FEF572@SACEXCMBX04-PRD.hq.netapp.com>
 <20120927153928.GB18962@8bytes.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA908FEF7A3@SACEXCMBX04-PRD.hq.netapp.com>
 <20120927175623.GG10549@amd.com>
 <506497B9.3030601@netapp.com>
 <20120928121733.GD18962@8bytes.org>
 <5065A456.4070007@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
In-Reply-To: <5065A456.4070007@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 28, 2012 at 09:21:26AM -0400, Bryan Schumaker wrote:
> On 09/28/2012 08:17 AM, Joerg Roedel wrote:

> Maybe it's mounting over v3 now?  Can you retry using "vers=4" in your mount options?

Tried that, mounting fails with 'No such file or directory'.


	Joerg

-- 
AMD Operating System Research Center

Advanced Micro Devices GmbH Einsteinring 24 85609 Dornach
General Managers: Alberto Bozzo
Registration: Dornach, Landkr. Muenchen; Registerger. Muenchen, HRB Nr. 43632

