Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:36322 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751177AbbDHIvg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Apr 2015 04:51:36 -0400
Received: by wizk4 with SMTP id k4so46540238wiz.1
        for <linux-nfs@vger.kernel.org>; Wed, 08 Apr 2015 01:51:35 -0700 (PDT)
Message-ID: <5524EC14.9030304@profitbricks.com>
Date: Wed, 08 Apr 2015 10:51:32 +0200
From: Michael Wang <yun.wang@profitbricks.com>
MIME-Version: 1.0
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Tom Talpey <tom@talpey.com>
CC: Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>,
        linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, Hal Rosenstock <hal.rosenstock@gmail.com>,
        Tom Tucker <tom@opengridcomputing.com>,
        Steve Wise <swise@opengridcomputing.com>,
        Hoang-Nam Nguyen <hnguyen@de.ibm.com>,
        Christoph Raisch <raisch@de.ibm.com>,
        Mike Marciniszyn <infinipath@intel.com>, Eli Cohen <eli@mellanox.com>,
        Faisal Latif <faisal.latif@intel.com>,
        Upinder Malhi <umalhi@cisco.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Ira Weiny <ira.weiny@intel.com>,
        PJ Waskiewicz <pj.waskiewicz@solidfire.com>,
        Tatyana Nikolova <Tatyana.E.Nikolova@intel.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Jack Morgenstein <jackm@dev.mellanox.co.il>,
        Haggai Eran <haggaie@mellanox.com>,
        Ilya Nelkenbaum <ilyan@mellanox.com>,
        Yann Droneaud <ydroneaud@opteya.com>,
        Bart Van Assche <bvanassche@acm.org>,
        Shachar Raindel <raindel@mellanox.com>,
        Sagi Grimberg <sagig@mellanox.com>,
        Devesh Sharma <devesh.sharma@emulex.com>,
        Matan Barak <matanb@mellanox.com>, Moni Shoua <monis@mellanox.com>,
        Jiri Kosina <jkosina@suse.cz>,
        Selvin Xavier <selvin.xavier@emulex.com>,
        Mitesh Ahuja <mitesh.ahuja@emulex.com>,
        Li RongQing <roy.qing.li@gmail.com>,
        Rasmus Villemoes <linux@rasmusvillemoes.dk>,
        Alex Estrin <alex.estrin@intel.com>,
        Doug Ledford <dledford@redhat.com>, Eric Dumazet <edumazet@google.com>,
        Erez Shitrit <erezsh@mellanox.com>, Tom Gundersen <teg@jklm.no>,
        Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH v2 09/17] IB/Verbs: Use helper cap_read_multi_sge() and
 reform svc_rdma_accept()
References: <5523CCD5.6030401@profitbricks.com> <5523CEE4.5060901@profitbricks.com> <5523FBF1.80304@talpey.com> <20150407174223.GB15704@obsidianresearch.com>
In-Reply-To: <20150407174223.GB15704@obsidianresearch.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/07/2015 07:42 PM, Jason Gunthorpe wrote:
[snip]
>>> @@ -992,8 +992,8 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
>>>  			dma_mr_acc = IB_ACCESS_LOCAL_WRITE;
>>>  		} else
>>>  			need_dma_mr = 0;
>>> -		break;
>>> -	case RDMA_TRANSPORT_IB:
>>> +	} else if (rdma_ib_mgmt(newxprt->sc_cm_id->device,
>>> +				newxprt->sc_cm_id->port_num)) {
>>>  		if (!(newxprt->sc_dev_caps & SVCRDMA_DEVCAP_FAST_REG)) {
>>>  			need_dma_mr = 1;
>>>  			dma_mr_acc = IB_ACCESS_LOCAL_WRITE;
>>
>> Now I'm even more confused. How is the presence of IB management
>> related to needing a privileged lmr?
> 
> Agree, this needs to be someone else. 
> 
> I think the test is probably based on this comment:
> 
>         * NB:  iWARP requires remote write access for the data sink
>         *      of an RDMA_READ. IB does not.
> 
> So the if should be:
> 
>           if (cap_rdma_read_needs_write(..) && 
> 	  !(newxprt->sc_dev_caps & SVCRDMA_DEVCAP_FAST_REG)) {
>                        need_dma_mr = 1;
>                        dma_mr_acc =
>                                (IB_ACCESS_LOCAL_WRITE |
>                                 IB_ACCESS_REMOTE_WRITE);
> 
> And the identical if blocks merged.
> 
> Plus the
> 	if (rdma_transport_iwarp(newxprt->sc_cm_id->device,
> 				 newxprt->sc_cm_id->port_num))
>   		newxprt->sc_dev_caps |= SVCRDMA_DEVCAP_READ_W_INV

Sounds good :-) I'll give this part a reform in next version.

Regards,
Michael Wang

> 
> Jason
> 
