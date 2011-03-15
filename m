From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 07/17] net,rcu: convert
 call_rcu(inet6_ifa_finish_destroy_rcu) to kfree_rcu()
Date: Tue, 15 Mar 2011 14:03:33 -0700 (PDT)
Message-ID: <20110315.140333.112590317.davem@davemloft.net>
References: <4D7F3610.6000809@cn.fujitsu.com>
	<4D7F38AE.7060708@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: mingo@elte.hu, paulmck@linux.vnet.ibm.com, axboe@kernel.dk,
	Trond.Myklebust@netapp.com, vladislav.yasevich@hp.com,
	sri@us.ibm.com, viro@zeniv.linux.org.uk, eparis@redhat.com,
	menage@google.com, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	johannes@sipsolutions.net, linville@tuxdriver.com, hadi@cyberus.ca,
	jpirko@redhat.com, eric.dumazet@gmail.com, hagen@jauu.net,
	randy.dunlap@oracle.com, jkosina@suse.cz, joe@perches.com,
	u.kleine-koenig@pengutronix.de, ebiederm@xmission.com,
	gregkh@suse.de, xemul@openvz.org, linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	linux-decnet-user@lists.sourceforge.net,
	linux-wireless@vger.kernel.org,
	linux-security-module@vger.kernel.org
To: laijs@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <4D7F38AE.7060708@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Lai Jiangshan <laijs@cn.fujitsu.com>
Date: Tue, 15 Mar 2011 18:00:14 +0800

> 
> 
> The rcu callback inet6_ifa_finish_destroy_rcu() just calls a kfree(),
> so we use kfree_rcu() instead of the call_rcu(inet6_ifa_finish_destroy_rcu).
> 
> Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>

Acked-by: David S. Miller <davem@davemloft.net>
