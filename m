From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 3/5] can: af_can.c use rcu_barrier() on module unload.
Date: Wed, 10 Jun 2009 11:02:50 +0100
Message-ID: <20090610110250.17644ae4@lxorguk.ukuu.org.uk>
References: <20090608130959.10052.54590.stgit@localhost>
	<20090608131138.10052.5408.stgit@localhost>
	<4A2D112A.4000308@hartkopp.net>
	<20090610.011027.43904351.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
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

On Wed, 10 Jun 2009 01:10:27 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Oliver Hartkopp <oliver@hartkopp.net>
> Date: Mon, 08 Jun 2009 15:24:58 +0200
> 
> > Acked-By: Oliver Hartkopp <oliver@hartkopp.net>
> 
> Please don't capitalize the "By" in "Acked-By".  Otherwise
> patchwork doesn't pick them up automatically.

Dave. We have computers to do all the silly tedious pointless jobs in
life, please just fix the scripts.

Alan
