From: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>
Subject: Re: [NFS] problems with lockd in 2.6.22.6
Date: Sat, 8 Sep 2007 20:20:52 +0200
Message-ID: <200709082020.52694.wolfgang.walter@studentenwerk.mhn.de>
References: <200709071749.55760.wolfgang.walter@studentenwerk.mhn.de> <20070907161945.GI24638@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: neilb@suse.de, netdev@vger.kernel.org, nfs@lists.sourceforge.net
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20070907161945.GI24638@fieldses.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Friday 07 September 2007, J. Bruce Fields wrote:
> On Fri, Sep 07, 2007 at 05:49:55PM +0200, Wolfgang Walter wrote:
> > Hello,
> >=20

> > 3) For unknown reason these sockets then remain open. In the mornin=
g
> > when people start their workstation again we therefor not only get =
a
> > lot of these messages again but often the nfs-server does not probe=
rly
> > work any more. Restarting the nfs-daemon is a workaround.
>=20

I wonder why these sockets remain open, by the way. Even if they aren't=
 used
for days. Such a socket only gets deleted when the 81. socket must be o=
pened.

If I do not misunderstand the idea then temporary sockets should be des=
troyed
after some time without activity by svc_age_temp_sockets.

Now I wonder how svc_age_temp_sockets works. Does it ever close and del=
ete a
temporary socket at all?


static void
svc_age_temp_sockets(unsigned long closure)
{
	struct svc_serv *serv =3D (struct svc_serv *)closure;
	struct svc_sock *svsk;
	struct list_head *le, *next;
	LIST_HEAD(to_be_aged);

	dprintk("svc_age_temp_sockets\n");

	if (!spin_trylock_bh(&serv->sv_lock)) {
		/* busy, try again 1 sec later */
		dprintk("svc_age_temp_sockets: busy\n");
		mod_timer(&serv->sv_temptimer, jiffies + HZ);
		return;
	}

	list_for_each_safe(le, next, &serv->sv_tempsocks) {
		svsk =3D list_entry(le, struct svc_sock, sk_list);

		if (!test_and_set_bit(SK_OLD, &svsk->sk_flags))
			continue;
		if (atomic_read(&svsk->sk_inuse) || test_bit(SK_BUSY, &svsk->sk_flags=
))
			continue;
####
doesn't this mean that svsk->sk_inuse must be zero which means that SK_=
DEAD is set?
and wouldn't that mean that svc_delete_socket already has been called f=
or that socket
(and probably is already closed) ?
and wouldn't that mean that svc_sock_enqueue which is called later does=
 not make any
sense (it checks for SK_DEAD)?
####

		atomic_inc(&svsk->sk_inuse);
		list_move(le, &to_be_aged);
		set_bit(SK_CLOSE, &svsk->sk_flags);
		set_bit(SK_DETACHED, &svsk->sk_flags);
	}
	spin_unlock_bh(&serv->sv_lock);

	while (!list_empty(&to_be_aged)) {
		le =3D to_be_aged.next;
		/* fiddling the sk_list node is safe 'cos we're SK_DETACHED */
		list_del_init(le);
		svsk =3D list_entry(le, struct svc_sock, sk_list);

		dprintk("queuing svsk %p for closing, %lu seconds old\n",
			svsk, get_seconds() - svsk->sk_lastrecv);

		/* a thread will dequeue and close it soon */
		svc_sock_enqueue(svsk);
		svc_sock_put(svsk);
	}

	mod_timer(&serv->sv_temptimer, jiffies + svc_conn_age_period * HZ);
}

Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
