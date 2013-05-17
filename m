Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.194]:53879 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756576Ab3EQWbD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 May 2013 18:31:03 -0400
Date: Fri, 17 May 2013 18:30:56 -0400
From: Jim Rees <rees@umich.edu>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] nfsd: avoid undefined signed overflow
Message-ID: <20130517223056.GA2776@umich.edu>
References: <1368826380-9864-1-git-send-email-rees@umich.edu>
 <20130517214031.GA14005@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130517214031.GA14005@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bruce Fields wrote:

  On Fri, May 17, 2013 at 05:33:00PM -0400, Jim Rees wrote:
  > In C, signed integer overflow results in undefined behavior, but unsigned
  > overflow wraps around. So do the subtraction first, then cast to signed.
  
  Thanks!  Applying for 3.11.
  
  (I wonder if it actually bites anyone in practice?  Are there common
  compilers or architectures where this makes a difference?  Even if so I
  suppose that many generations is probably unlikely enough not to make
  this worth backporting to stable branches.)

I tested on the architectures I have at my fingertips and it made no
difference. My guess is you might need a one's complement architecture. Of
course we'll never see wraparound in our lifetimes, so no sense backporting
this.

I actually used a one's complement machine many years ago, a CDC 6600. I
don't think linux has been ported to it.
