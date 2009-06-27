From: Christian Kujau <lists@nerdbynature.de>
Subject: Re: [PATCH 07/10] decnet: Use rcu_barrier() on module unload.
Date: Fri, 26 Jun 2009 20:15:57 -0700 (PDT)
Message-ID: <alpine.DEB.2.01.0906262010091.6439@bogon>
References: <1245845367.24921.3.camel@localhost.localdomain> <5A680E0A-EFEB-44EA-9F06-F338E6CBD6D1@googlemail.com> <1245930729.24921.67.camel@localhost.localdomain> <20090625.161046.19938291.davem@davemloft.net>
 <Pine.LNX.4.64.0906262100210.14848@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	Jesper Dangaard Brouer <jdb@comx.dk>,
	paulmck@linux.vnet.ibm.com, netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>, yoshfuji@linux-ipv6.org,
	linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org,
	catalin.marinas@gmail.com
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <linux-ext4-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0906262100210.14848@ask.diku.dk>
Sender: linux-ext4-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 26 Jun 2009, Jesper Dangaard Brouer wrote:
> I'll resubmit the patches to you and netdev, to limit the spam effect...

Out of curiosity: why was linux-ext4 Cc'ed on these rcu_barrier patches
(but not other fs-lists but linux-nfs)? I did not see any ../fs/ext4/ 
changes.

Christian.
-- 
BOFH excuse #6:

global warming
