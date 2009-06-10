From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH 3/5] can: af_can.c use rcu_barrier() on module unload.
Date: Wed, 10 Jun 2009 13:33:15 +0200 (CEST)
Message-ID: <alpine.LSU.2.00.0906101327400.30984@fbirervta.pbzchgretzou.qr>
References: <20090608130959.10052.54590.stgit@localhost> <20090608131138.10052.5408.stgit@localhost> <4A2D112A.4000308@hartkopp.net> <20090610.011027.43904351.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: oliver@hartkopp.net, hawk@comx.dk, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	urs.thuermann@volkswagen.de, oliver.hartkopp@volkswagen.de,
	wg@grandegger.com, vladislav.yasevich@hp.com, sri@us.ibm.com,
	linux-sctp@vger.kernel.org, Trond.Myklebust@netapp.com,
	linux-nfs@vger.kernel.org, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090610.011027.43904351.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Wednesday 2009-06-10 10:10, David Miller wrote:
>> Acked-By: Oliver Hartkopp <oliver@hartkopp.net>
>
>Please don't capitalize the "By" in "Acked-By".  Otherwise
>patchwork doesn't pick them up automatically.

Is not that a patchwork bug then that should be reported? Or a
missing feature to checkpatch? Do we need a CodingStyle for
SOBs now too, just for that?

(Personally I prefer lowercase after the dash too, but I wanted to
illuminate all sides of the box.)
