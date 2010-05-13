From: "Batsakis, Alexandros" <Alexandros.Batsakis@netapp.com>
Subject: RE: [PATCH 2/3] SQUASHME pnfs_submit: update DS nfs4_set_client
Date: Thu, 13 May 2010 12:29:10 -0700
Message-ID: <B9364369CA66BF45806C2CD86EAB8BA60607E6BB@SACMVEXC3-PRD.hq.netapp.com>
References: <1273685980-3340-1-git-send-email-andros@netapp.com> <1273685980-3340-2-git-send-email-andros@netapp.com> <1273685980-3340-3-git-send-email-andros@netapp.com> <B9364369CA66BF45806C2CD86EAB8BA60607E6A4@SACMVEXC3-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <linux-nfs@vger.kernel.org>
To: "Batsakis, Alexandros" <Alexandros.Batsakis@netapp.com>,
	"Adamson, Andy" <William.Adamson@netapp.com>, <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:57543 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751070Ab0EMT3L convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 May 2010 15:29:11 -0400
In-Reply-To: <B9364369CA66BF45806C2CD86EAB8BA60607E6A4-hX7t0kiaRRqx3DEm5hsDiAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> -----Original Message-----
> From: Batsakis, Alexandros
> Sent: Thursday, May 13, 2010 12:14 PM
> To: Adamson, Andy; bhalevy@panasas.com
> Cc: linux-nfs@vger.kernel.org
> Subject: RE: [PATCH 2/3] SQUASHME pnfs_submit: update DS
> nfs4_set_client
> 
> 
> 
> > -----Original Message-----
> > From: Adamson, Andy
> > Sent: Wednesday, May 12, 2010 10:40 AM
> > To: bhalevy@panasas.com
> > Cc: linux-nfs@vger.kernel.org; Adamson, Andy
> > Subject: [PATCH 2/3] SQUASHME pnfs_submit: update DS nfs4_set_client
> >
> > From: Andy Adamson <andros@netapp.com>
> >
> > Dont bother using the hostname, use the client ipaddr field from the
> > MDS
> > nfs_client for construction of the co_ownrid field the DS
> EXCHANGE_ID.
> >
> > Clean up the comments.
> >
> > Squash into "pnfs: filelayout: device ops"
> >
> > Signed-off-by: Andy Adamson <andros@netapp.com>
> > ---
> >  fs/nfs/nfs4filelayoutdev.c |   28 +++++-----------------------
> >  1 files changed, 5 insertions(+), 23 deletions(-)
> >
> > diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
> > index 891c31d..b41f437 100644
> > --- a/fs/nfs/nfs4filelayoutdev.c
> > +++ b/fs/nfs/nfs4filelayoutdev.c
> > @@ -128,8 +128,6 @@ nfs4_pnfs_ds_create(struct nfs_server *mds_srv,
> > struct nfs4_pnfs_ds *ds)
> >  	struct rpc_clnt 	*mds_clnt = mds_srv->client;
> >  	struct nfs_client	*clp = mds_srv->nfs_client;
> >  	struct sockaddr		*mds_addr;
> > -	char			ip_addr[16];
> > -	int			addrlen;
> >  	int err = 0;
> >
> >  	dprintk("--> %s ip:port %s au_flavor %d\n", __func__,
> > @@ -156,32 +154,16 @@ nfs4_pnfs_ds_create(struct nfs_server
*mds_srv,
> > struct nfs4_pnfs_ds *ds)
> >  		}
> >  		goto out;
> >  	}
> > -	/* Set timeout to the mds rpc clnt value.
> > -	 * XXX - find the correct authflavor....
> > -	 *
> > -	 * Fake a client ipaddr (used for sessionid) with hostname
> > -	 * Use hostname since it might be more unique than ipaddr (which
> > -	 * could be set to the loopback 127.0.0/1.1
> > -	 *
> > -	 * XXX: Should sessions continue to use the cl_ipaddr field?
> > -	 */
> > -	addrlen = strnlen(utsname()->nodename, sizeof(utsname()-
> > >nodename));
> > -	if (addrlen > sizeof(ip_addr))
> > -		addrlen = sizeof(ip_addr);
> > -	memcpy(ip_addr, utsname()->nodename, addrlen);
> > -
> > -	/* XXX need a non-nfs_client struct interface to set up
> > -	 * data server sessions
> > -	 *
> > -	 * tmp: nfs4_set_client sets the nfs_server->nfs_client.
> > -	 *
> > -	 * We specify a retrans and timeout interval equual to MDS. ??
> > +	/*
> > +	 * Set a retrans, timeout interval, and authflavor equual to the
> > MDS
> > +	 * values. Use the MDS nfs_client cl_ipaddr field so as to use
> > the
> > +	 * same co_ownerid as the MDS.
> >  	 */
> >  	err = nfs4_set_client(&tmp,
> >  			      mds_srv->nfs_client->cl_hostname,
> >  			      (struct sockaddr *)&sin,
> >  			      sizeof(struct sockaddr),
> > -			      ip_addr,
> > +			      mds_srv->nfs_client->cl_ipaddr,
> >  			      mds_clnt->cl_auth->au_flavor,
> >  			      IPPROTO_TCP,
> >  			      mds_clnt->cl_xprt->timeout,
> > --
> > 1.6.6
> 
> Hi Andy,
> 
> Is there a way to avoid creating a new nfs_client altogether and just
> re-use the existing one along with its session ?
> 
> -a
> 

Nevermind. I should have read patch 1/3 as well :)

-a

> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs"
> in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
