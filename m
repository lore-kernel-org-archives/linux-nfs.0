From: Gyorgy Jeney <nog.lkml@gmail.com>
Subject: Re: NFS over RDMA problem: svcrdma: Error fast registering memory for
	xprt ffff8803307d7400
Date: Wed, 14 Jul 2010 23:17:23 +0200
Message-ID: <AANLkTik-BR1txJIbbzaB8YKJQM5lswbmWpbhKSdeUseg@mail.gmail.com>
References: <AANLkTinjZfpICMjP1EcU4CPAe1TwxKp1zsk-lwX6fmzA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Return-path: <linux-rdma-owner@vger.kernel.org>
In-Reply-To: <AANLkTinjZfpICMjP1EcU4CPAe1TwxKp1zsk-lwX6fmzA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> I am attempting to use NFS over RDMA (over infiniband), but there is =
some
> problem. =A0The NFS filesystem can be mounted on the client, and thin=
gs
> will work for some time (can read, modify, etc. the files over the mo=
unt),
> but then (at a seemingly random time) the NFS server will dump these
> lines to the logs:
>
> [ 4380.623922] svcrdma: Error fast registering memory for xprt ffff88=
03307d7400
> [ 4413.343161] svcrdma: error fast registering xdr for xprt ffff88033=
19edc00

Digging into it further, it seems like the Mellanox Infiniband driver
could somehow be involved.  Adding some trace's to the code, it's obvio=
us
something like this is happening:

At some time sq_cq_reap() is called, which ends up like this:

  sq_cq_reap()
    ib_poll_cq()
      mlx4_ib_poll_cq()
        mlx4_ib_poll_one()
          mlx4_ib_handle_error_cqe()
            - Which then sets wc->status to IB_WC_WR_FLUSH_ERR rather
              often, but the killer blow seems to be when
              IB_WC_REM_ACCESS_ERR is set.
    - Because of the error previously, sq_cq_reap sets the XPT_CLOSE
      flag

Then, sometime later:

  fast_reg_read_chunks()
    svc_rdma_fastreg()
      svc_rdma_send()
        svc_rdma_send()
          - XPT_CLOSE is set and hence -ENOTCONN is returned
    - Since svc_rdma_fastreg() had an error fast_reg_read_chunks() bail=
s
      and the client seems to then hang.

I'd ask the infiband guys, what does IB_WC_WR_FLUSH_ERR and
IB_WC_REM_ACCESS_ERR mean?  Is it something drastic that should result
in hangs?

nog.

> Both client and server are running the latest vanilla 2.6.34.1 kernel
> with Mellanox Connect-X infiniband cards. =A0If more information is
> required, please do ask.
>
> BTW: I can reproduce the problem quite reliably by running the bonnie=
++
> "benchmark" on the NFS mounted filesystem.
>
> nog.
>
> ps: I'm not subscribed to the list, please CC me on all replies.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
