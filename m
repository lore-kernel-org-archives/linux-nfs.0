From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 08/17] net,rcu: convert call_rcu(listeners_free_rcu) to
	kfree_rcu()
Date: Tue, 15 Mar 2011 14:03:44 -0700 (PDT)
Message-ID: <20110315.140344.183052861.davem@davemloft.net>
References: <4D7F3610.6000809@cn.fujitsu.com> <4D7F3906.3090107@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: randy.dunlap@oracle.com, linux-decnet-user@lists.sourceforge.net,
        Trond.Myklebust@netapp.com, linux-sctp@vger.kernel.org,
        xemul@openvz.org, pekkas@netcore.fi, eric.dumazet@gmail.com,
        u.kleine-koenig@pengutronix.de, kuznet@ms2.inr.ac.ru, mingo@elte.hu,
        paulmck@linux.vnet.ibm.com, sri@us.ibm.com, vladislav.yasevich@hp.com,
        hagen-GvnIQ6b/HdU@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, viro@zeniv.linux.org.uk,
        menage@google.com, axboe@kernel.dk, linux-nfs@vger.kernel.org,
        jpirko@redhat.com, yoshfuji@linux-ipv6.org, jkosina@suse.cz,
        containers@lists.linux-foundation.org, gregkh@suse.de,
        linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
        eparis@redhat.com, linux-security-module@vger.kernel.org,
        ebiederm@xmission.com, netdev@vger.kernel.org, joe@perches.com,
        johannes@sipsolutions.net
To: laijs@cn.fujitsu.com
Return-path: <containers-bounces@lists.linux-foundation.org>
In-Reply-To: <4D7F3906.3090107@cn.fujitsu.com>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers@lists.linux-foundation.org>
List-Help: <mailto:containers-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request@lists.linux-foundation.org?subject=subscribe>
Sender: containers-bounces@lists.linux-foundation.org
Errors-To: containers-bounces@lists.linux-foundation.org
List-ID: <linux-nfs.vger.kernel.org>

From: Lai Jiangshan <laijs@cn.fujitsu.com>
Date: Tue, 15 Mar 2011 18:01:42 +0800

> 
> 
> The rcu callback listeners_free_rcu() just calls a kfree(),
> so we use kfree_rcu() instead of the call_rcu(listeners_free_rcu).
> 
> Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>

Acked-by: David S. Miller <davem@davemloft.net>
