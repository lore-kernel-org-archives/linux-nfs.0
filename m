From: Paul Menage <menage@google.com>
Subject: Re: [PATCH 01/17] cgroup,
	rcu: convert call_rcu(free_css_set_rcu) to kfree_rcu()
Date: Tue, 15 Mar 2011 13:03:39 -0700
Message-ID: <AANLkTink63LmMabe4_MzeHbFRSpqgkajUreKCOp004Sn@mail.gmail.com>
References: <4D7F3610.6000809@cn.fujitsu.com> <4D7F372A.6050407@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Randy Dunlap <randy.dunlap@oracle.com>,
        linux-decnet-user@lists.sourceforge.net,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-sctp@vger.kernel.org, Pavel Emelyanov <xemul@openvz.org>,
        "Pekka Savola \(ipv6\)" <pekkas@netcore.fi>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        =?ISO-8859-1?Q?Uwe_Kleine=2DK=F6nig?= <u.kleine-koenig@pengutronix.de>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Ingo Molnar <mingo@elte.hu>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Sridhar Samudrala <sri@us.ibm.com>,
        Vlad Yasevich <vladislav.yasevich@hp.com>,
        Hagen Paul Pfeifer <hagen-GvnIQ6b/HdU@public.gmane.org>,
        "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
        Al Viro <viro@zeniv.linux.org.uk>, Jens Axboe <axboe@kernel.dk>,
        linux-nfs@vger.kernel.org, Jiri Pirko <jpirko@redhat.com>,
        Hideaki YOSHIFUJI <yoshfu
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Return-path: <containers-bounces@lists.linux-foundation.org>
In-Reply-To: <4D7F372A.6050407@cn.fujitsu.com>
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

2011/3/15 Lai Jiangshan <laijs@cn.fujitsu.com>:
>
> The rcu callback free_css_set_rcu() just calls a kfree(),
> so we use kfree_rcu() instead of the call_rcu(free_css_set_rcu).
>
> Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>

Acked-by: Paul Menage <menage@google.com>

Looks fine, assuming the main kfree_rcu() changes go through.

Paul
