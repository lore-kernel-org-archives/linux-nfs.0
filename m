From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] We must use rcu_barrier() on module unload
Date: Wed, 10 Jun 2009 01:11:55 -0700 (PDT)
Message-ID: <20090610.011155.231596832.davem@davemloft.net>
References: <20090608130959.10052.54590.stgit@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: paulmck@linux.vnet.ibm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, urs.thuermann-l29pVbxQd1IUtdQbppsyvg@public.gmane.org,
	oliver.hartkopp-l29pVbxQd1IUtdQbppsyvg@public.gmane.org, wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org,
	vladislav.yasevich@hp.com, sri@us.ibm.com,
	linux-sctp@vger.kernel.org, Trond.Myklebust@netapp.com,
	linux-nfs@vger.kernel.org, netfilter-devel@vger.kernel.org
To: hawk-4UpuNZONu4c@public.gmane.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50051
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757911AbZFJILx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Jun 2009 04:11:53 -0400
In-Reply-To: <20090608130959.10052.54590.stgit@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jesper Dangaard Brouer <hawk-4UpuNZONu4c@public.gmane.org>
Date: Mon, 08 Jun 2009 15:11:23 +0200

> If an unloadable module uses RCU callbacks, it need to use
> rcu_barrier() so that the module may be safely unloaded.
 ...
> The patchset is made on top of DaveM's net-next-2.6 tree (starting on
> top of commit a1c1db392090). As this is my usual development tree,
> even though this patchset is bugfixes. (Just tested it applied cleanly
> on Linus'es tree ...)

All 5 patches applied, thanks!
