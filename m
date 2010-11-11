From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [regression] NFS readdir change break fully cached nfs root
Date: Thu, 11 Nov 2010 20:08:02 +0100
Message-ID: <20101111190802.GH18718@basil.fritz.box>
References: <20101102180051.GA26089@basil.fritz.box>
 <1288731930.534.1.camel@heimdal.trondhjem.org>
 <20101103162423.GA3797@elliptictech.com>
 <1288886814.3285.5.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nick Bowler <nbowler@elliptictech.com>,
	Andi Kleen <andi@firstfloor.org>, bjschuma@netapp.com,
	torvalds@linux-foundation.org, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1288886814.3285.5.camel@heimdal.trondhjem.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Trond, I noticed that this is still broken in Linus' current tree,
somewhat disrupting testing here. Could you please submit the fixes
for this ASAP?

Thanks,
-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.
