From: Olaf Kirch <olaf.kirch@oracle.com>
Subject: Re: [NFS] [PATCH 001 of 3] knfsd: Use recv_msg to get peer address for NFSD instead of code-copying
Date: Mon, 5 Mar 2007 19:59:55 +0100
Message-ID: <200703051959.56914.olaf.kirch@oracle.com>
References: <20070302151748.5226.patches@notabene> <1070302042825.5760@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: NeilBrown <neilb@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: nfs@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1070302042825.5760@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>


Hi Neil,

here's another minor comment:

On Friday 02 March 2007 05:28, NeilBrown wrote:
> +static inline void svc_udp_get_dest_address(struct svc_rqst *rqstp,
> +					    struct cmsghdr *cmh)
>  {
>  	switch (rqstp->rq_sock->sk_sk->sk_family) {
>  	case AF_INET: {
> +		struct in_pktinfo *pki = CMSG_DATA(cmh);
> +		rqstp->rq_daddr.addr.s_addr = pki->ipi_spec_dst.s_addr;
>  		break;
> +		}
...

The daddr that is extracted here will only ever be used to build
another PKTINFO cmsg when sending the reply. So it would be
much easier to just store the raw control message in the svc_rqst,
without looking at its contents, and send it out along with the reply,
unchanged.

Olaf
-- 
Olaf Kirch  |  --- o --- Nous sommes du soleil we love when we play
okir@lst.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax
