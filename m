From: Paul Menage <menage@google.com>
Subject: Re: [PATCH 03/17] cgroup,
	rcu: convert call_rcu(__free_css_id_cb) to kfree_rcu()
Date: Tue, 15 Mar 2011 13:04:33 -0700
Message-ID: <AANLkTi=coPDZRv7ydnP4q-Qztq=FLaa+neNjTvcFowAE@mail.gmail.com>
References: <4D7F3610.6000809@cn.fujitsu.com> <4D7F37BA.5000308@cn.fujitsu.com>
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
In-Reply-To: <4D7F37BA.5000308@cn.fujitsu.com>
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
>
> The rcu callback __free_css_id_cb() just calls a kfree(),
> so we use kfree_rcu() instead of the call_rcu(__free_css_id_cb).
>
> Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>

Acked-by: Paul Menage <menage@google.com>


> ---
> =A0kernel/cgroup.c | =A0 10 +---------
> =A01 files changed, 1 insertions(+), 9 deletions(-)
>
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 5c83c91..b7d3f6d 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -4612,14 +4612,6 @@ bool css_is_ancestor(struct cgroup_subsys_state *c=
hild,
> =A0 =A0 =A0 =A0return ret;
> =A0}
>
> -static void __free_css_id_cb(struct rcu_head *head)
> -{
> - =A0 =A0 =A0 struct css_id *id;
> -
> - =A0 =A0 =A0 id =3D container_of(head, struct css_id, rcu_head);
> - =A0 =A0 =A0 kfree(id);
> -}
> -
> =A0void free_css_id(struct cgroup_subsys *ss, struct cgroup_subsys_state =
*css)
> =A0{
> =A0 =A0 =A0 =A0struct css_id *id =3D css->id;
> @@ -4634,7 +4626,7 @@ void free_css_id(struct cgroup_subsys *ss, struct c=
group_subsys_state *css)
> =A0 =A0 =A0 =A0spin_lock(&ss->id_lock);
> =A0 =A0 =A0 =A0idr_remove(&ss->idr, id->id);
> =A0 =A0 =A0 =A0spin_unlock(&ss->id_lock);
> - =A0 =A0 =A0 call_rcu(&id->rcu_head, __free_css_id_cb);
> + =A0 =A0 =A0 kfree_rcu(id, rcu_head);
> =A0}
> =A0EXPORT_SYMBOL_GPL(free_css_id);
>
> --
> 1.7.4
>
