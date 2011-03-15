From: Paul Menage <menage@google.com>
Subject: Re: [PATCH 02/17] cgroup,
	rcu: convert call_rcu(free_cgroup_rcu) to kfree_rcu()
Date: Tue, 15 Mar 2011 13:04:00 -0700
Message-ID: <AANLkTim-BeRO7DJA4bqKrxED4FbWeV3R-U6cciEkyUQo@mail.gmail.com>
References: <4D7F3610.6000809@cn.fujitsu.com> <4D7F3784.6090307@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
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
In-Reply-To: <4D7F3784.6090307@cn.fujitsu.com>
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
> The rcu callback free_cgroup_rcu() just calls a kfree(),
> so we use kfree_rcu() instead of the call_rcu(free_cgroup_rcu).
>
> Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>

Acked-by: Paul Menage <menage@google.com>

> ---
> =A0kernel/cgroup.c | =A0 =A09 +--------
> =A01 files changed, 1 insertions(+), 8 deletions(-)
>
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index ad485d4..5c83c91 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -806,13 +806,6 @@ static int cgroup_call_pre_destroy(struct cgroup *cg=
rp)
> =A0 =A0 =A0 =A0return ret;
> =A0}
>
> -static void free_cgroup_rcu(struct rcu_head *obj)
> -{
> - =A0 =A0 =A0 struct cgroup *cgrp =3D container_of(obj, struct cgroup, rc=
u_head);
> -
> - =A0 =A0 =A0 kfree(cgrp);
> -}
> -
> =A0static void cgroup_diput(struct dentry *dentry, struct inode *inode)
> =A0{
> =A0 =A0 =A0 =A0/* is dentry a directory ? if so, kfree() associated cgrou=
p */
> @@ -850,7 +843,7 @@ static void cgroup_diput(struct dentry *dentry, struc=
t inode *inode)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0BUG_ON(!list_empty(&cgrp->pidlists));
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 call_rcu(&cgrp->rcu_head, free_cgroup_rcu);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree_rcu(cgrp, rcu_head);
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0iput(inode);
> =A0}
> --
> 1.7.4
>
