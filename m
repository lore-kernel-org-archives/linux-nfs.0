Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:40765 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757821AbaDXPsm convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Apr 2014 11:48:42 -0400
From: Devesh Sharma <Devesh.Sharma@Emulex.Com>
To: Chuck Lever <chuck.lever@oracle.com>,
        Sagi Grimberg <sagig@dev.mellanox.co.il>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: RE: [PATCH V1] NFS-RDMA: fix qp pointer validation checks
Date: Thu, 24 Apr 2014 15:48:40 +0000
Message-ID: <EE7902D3F51F404C82415C4803930ACD3FDF4F83@CMEXMB1.ad.emulex.com>
References: <014738b6-698e-4ea1-82f9-287378bfec19@CMEXHTCAS2.ad.emulex.com>
 <D7AB2150-5F25-4BA2-80D9-94890AD11F8F@primarydata.com>
 <F1C70AD6-BDD4-4534-8DC4-61D2767581D9@oracle.com>
 <EE7902D3F51F404C82415C4803930ACD3FDEAA43@CMEXMB1.ad.emulex.com>
 <E66D006A-0D04-4602-8BF5-6834CACD2E24@oracle.com>
 <EE7902D3F51F404C82415C4803930ACD3FDEB3B4@CMEXMB1.ad.emulex.com>
 <BD7B05C0-4733-4DD1-83F3-B30B6B0EE48C@oracle.com>
 <EE7902D3F51F404C82415C4803930ACD3FDEB3DF@CMEXMB1.ad.emulex.com>
 <56C87770-7940-4006-948C-FEF3C0EC4ACC@oracle.com>
 <EE7902D3F51F404C82415C4803930ACD3FDEBD66@CMEXMB1.ad.emulex.com>
 <5710A71F-C4D5-408B-9B41-07F21B5853F0@oracle.com>
 <6837A427-B677-4CC7-A022-4FB9E52A3FC6@oracle.com>
 <EE7902D3F51F404C82415C4803930ACD3FDED915@CMEXMB1.ad.emulex.com>
 <C689AB91-46F6-4E96-A673-0DE76FE54CC4@oracle.com>
 <EE7902D3F51F404C82415C4803930ACD3FDEE11F@CMEXMB1.ad.emulex.com>
 <1bab6615-60c4-4865-a6a0-c53bb1c32341@CMEXHTCAS1.ad.emulex.com>
 <5358B975.4020207@dev.mellanox.co.il>
 <B39C0B38-357F-4BDA-BDA7-048BD38853F7@oracle.com>
In-Reply-To: <B39C0B38-357F-4BDA-BDA7-048BD38853F7@oracle.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks Chuck for summarizing.
One more issue is being added to the list below.

> -----Original Message-----
> From: linux-rdma-owner@vger.kernel.org [mailto:linux-rdma-
> owner@vger.kernel.org] On Behalf Of Chuck Lever
> Sent: Thursday, April 24, 2014 8:31 PM
> To: Sagi Grimberg
> Cc: Devesh Sharma; Linux NFS Mailing List; linux-rdma@vger.kernel.org;
> Trond Myklebust
> Subject: Re: [PATCH V1] NFS-RDMA: fix qp pointer validation checks
> 
> 
> On Apr 24, 2014, at 3:12 AM, Sagi Grimberg <sagig@dev.mellanox.co.il>
> wrote:
> 
> > On 4/24/2014 2:30 AM, Devesh Sharma wrote:
> >> Hi Chuck
> >>
> >> Following is the complete call trace of a typical NFS-RDMA transaction
> while mounting a share.
> >> It is unavoidable to stop calling post-send in case it is not
> >> created. Therefore, applying checks to the connection state is a must
> While registering/deregistering frmrs on-the-fly. The unconnected state of
> QP implies don't call  post_send/post_recv from any context.
> >>
> >
> > Long thread... didn't follow it all.
> 
> I think you got the gist of it.
> 
> > If I understand correctly this race comes only for *cleanup* (LINV) of FRMR
> registration while teardown flow destroyed the QP.
> > I think this might be disappear if for each registration you post LINV+FRMR.
> > This is assuming that a situation where trying to post Fastreg on a
> > "bad" QP can never happen (usually since teardown flow typically suspends
> outgoing commands).
> 
> That's typically true for "hard" NFS mounts. But "soft" NFS mounts wake
> RPCs after a timeout while the transport is disconnected, in order to kill
> them.  At that point, deregistration still needs to succeed somehow.
> 
> IMO there are three related problems.
> 
> 1.  rpcrdma_ep_connect() is allowing RPC tasks to be awoken while
>     there is no QP at all (->qp is NULL). The woken RPC tasks are
>     trying to deregister buffers that may include page cache pages,
>     and it's oopsing because ->qp is NULL.
> 
>     That's a logic bug in rpcrdma_ep_connect(), and I have an idea
>     how to address it.
> 
> 2.  If a QP is present but disconnected, posting LOCAL_INV won't work.
>     That leaves buffers (and page cache pages, potentially) registered.
>     That could be addressed with LINV+FRMR. But...
> 
> 3.  The client should not leave page cache pages registered indefinitely.
>     Both LINV+FRMR and our current approach depends on having a working
>     QP _at_ _some_ _point_ ... but the client simply can't depend on that.
>     What happens if an NFS server is, say, destroyed by fire while there
>     are active client mount points? What if the HCA's firmware is
>     permanently not allowing QP creation?
Addition to the list
4. If rdma traffic is in progress and  the network link goes down and comes back up after some time (t > 10 secs ), 
    The rpcrdma_ep_connect() does not destroys the existing QP because rpcrdma_create_id fails (rdma_resolve_addr fails).
    Now, once the connect worker thread Gets rescheduled again, every time CM fails with establishment error. Finally, after multiple tries
    CM fails with rdma_cm_event = 15 and entire recovery thread sits silently forever and kernel reports user app is blocked for more than 120 secs. 
> 
> Here's a relevant comment in rpcrdma_ep_connect():
> 
>  815                 /* TEMP TEMP TEMP - fail if new device:
>  816                  * Deregister/remarshal *all* requests!
>  817                  * Close and recreate adapter, pd, etc!
>  818                  * Re-determine all attributes still sane!
>  819                  * More stuff I haven't thought of!
>  820                  * Rrrgh!
>  821                  */
> 
> xprtrdma does not do this today.
> 
> When a new device is created, all existing RPC requests could be
> deregistered and re-marshalled.  As far as I can tell,
> rpcrdma_ep_connect() is executing in a synchronous context (the connect
> worker) and we can simply use dereg_mr, as long as later, when the RPCs are
> re-driven, they know they need to re-marshal.
> 
> I'll try some things today.
> 
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in the
> body of a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html
