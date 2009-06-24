From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/10] We must use rcu_barrier() on module unload
Date: Wed, 24 Jun 2009 00:02:11 -0700 (PDT)
Message-ID: <20090624.000211.175032622.davem@davemloft.net>
References: <20090623150330.22490.87327.stgit@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: paulmck@linux.vnet.ibm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, dougthompson@xmission.com,
	bluesmoke-devel@lists.sourceforge.net, axboe@kernel.dk,
	kaber@trash.net, christine.caulfield@googlemail.com,
	Trond.Myklebust@netapp.com, linux-wireless@vger.kernel.org,
	johannes@sipsolutions.net, yoshfuji@linux-ipv6.org,
	shemminger@linux-foundation.org, linux-nfs@vger.kernel.org,
	bfields@fieldses.org, neilb@suse.de, linux-ext4@vger.kernel.org,
	tytso@mit.edu, adilger@sun.com, netfilter-devel@vger.kernel.org
To: hawk@comx.dk
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755407AbZFXHCT@vger.kernel.org>
In-Reply-To: <20090623150330.22490.87327.stgit@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jesper Dangaard Brouer <hawk@comx.dk>
Date: Tue, 23 Jun 2009 17:03:53 +0200

> This patch series is an attempt to cleanup the entire tree, for
> potential oops'es during module unload, due to outstanding RCU
> callbacks. (My last rcu_barrier patch series only addressed net/).

This series has net/ stuff too :-)

I'll let the networking cases sit for a while and get review before
I apply them.
