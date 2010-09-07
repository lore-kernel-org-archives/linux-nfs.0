Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:59194 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758339Ab0IGUyP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Sep 2010 16:54:15 -0400
Subject: Re: RFC:  support srcaddr= option to bind to local IPs.
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Ben Greear <greearb@candelatech.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
In-Reply-To: <4C86A36E.9010906@candelatech.com>
References: <4C81449B.4010900@candelatech.com>
	 <1283882166.2788.48.camel@heimdal.trondhjem.org>
	 <4C86A36E.9010906@candelatech.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 07 Sep 2010 16:54:11 -0400
Message-ID: <1283892851.2788.107.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2010-09-07 at 13:41 -0700, Ben Greear wrote:
> On 09/07/2010 10:56 AM, Trond Myklebust wrote:
> > On Fri, 2010-09-03 at 11:55 -0700, Ben Greear wrote:
> >> This patch lets one bind the local side of NFS sockets to a particular
> >> IP address.  This can be useful for users on multi-homed systems.
> >>
> >> This patch must be on top of the previous patch to fix the IPv6 address
> >> comparison or it will not work.
> >>
> >> Comments and suggestions welcome...I'll incorporate those and post an
> >> official signed-off patch after that.
> >>
> >> Thanks,
> >> Ben
> >>
> >
> > The code in nfs_callback_authenticate is going to break NFSv4 callbacks.
> > Callbacks are sent to the -oclientaddr address, not srcaddr (btw, I
> > really dislike that new boolean argument to nfs_find_client(). If you
> > don't want to compare the source address, then have the caller pass a
> > NULL pointer).
> 
> 
> Would this fix the callback issue you speak of?  The idea is to
> use source and dest to match if it exists, but if we find one
> where server address matches and srcaddr isn't specified,
> then we will use that.

No. As I said, it needs to match the clientaddr argument, not the
srcaddr.

The problem is that you are now potentially introducing cases where the
server may have multiple combinations of clientaddr and srcaddr.

> @@ -384,10 +390,30 @@ struct nfs_client *nfs_find_client(const struct sockaddr *addr, u32 nfsversion)
>                  if (!nfs_sockaddr_match_ipaddr(addr, clap))
>                          continue;
> 
> +               if (srcaddr) {
> +                       const struct sockaddr *sa;
> +                       sa = (const struct sockaddr *)&clp->srcaddr;
> +                       if (!nfs_sockaddr_match_ipaddr(srcaddr, sa)) {
> +                               /* If clp doesn't bind to srcaddr, then
> +                                * it is a potential match if we don't find
> +                                * a better one.
> +                                */
> +                               if (sa->sa_family == AF_UNSPEC && !ok_fit)
> +                                       ok_fit = clp;
> +                               continue;
> +                       }
> +               }
> +found_one:
>                  atomic_inc(&clp->cl_count);
>                  spin_unlock(&nfs_client_lock);
>                  return clp;
>          }
> +
> +       if (ok_fit) {
> +               clp = ok_fit;
> +               goto found_one;
> +       }
> +
>          spin_unlock(&nfs_client_lock);
>          return NULL;
>   }
> 
> 
> Thanks,
> Ben
> 



