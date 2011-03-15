From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 11/17] net,rcu: convert call_rcu(sctp_local_addr_free)
 to kfree_rcu()
Date: Tue, 15 Mar 2011 14:03:59 -0700 (PDT)
Message-ID: <20110315.140359.39186121.davem@davemloft.net>
References: <4D7F3610.6000809@cn.fujitsu.com>
	<4D7F39CE.80403@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: mingo@elte.hu, paulmck@linux.vnet.ibm.com, axboe@kernel.dk,
	Trond.Myklebust@netapp.com, vladislav.yasevich@hp.com,
	sri@us.ibm.com, viro@zeniv.linux.org.uk, eparis@redhat.com,
	menage@google.com, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	johannes@sipsolutions.net, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org,
	jpirko@redhat.com, eric.dumazet@gmail.com, hagen-GvnIQ6b/HdU@public.gmane.org,
	randy.dunlap@oracle.com, jkosina@suse.cz, joe@perches.com,
	u.kleine-koenig@pengutronix.de, ebiederm@xmission.com,
	gregkh@suse.de, xemul@openvz.org, linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	linux-decnet-user@lists.sourceforge.net,
	linux-wireless@vger.kernel.org,
	linux-security-module@vger.kernel.org
To: laijs@cn.fujitsu.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41186
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758748Ab1COVDX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Mar 2011 17:03:23 -0400
In-Reply-To: <4D7F39CE.80403@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Lai Jiangshan <laijs@cn.fujitsu.com>
Date: Tue, 15 Mar 2011 18:05:02 +0800

> 
> 
> The rcu callback sctp_local_addr_free() just calls a kfree(),
> so we use kfree_rcu() instead of the call_rcu(sctp_local_addr_free).
> 
> Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>

Acked-by: David S. Miller <davem@davemloft.net>
