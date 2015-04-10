Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:36264 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753792AbbDJIZ0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Apr 2015 04:25:26 -0400
Received: by wizk4 with SMTP id k4so119748918wiz.1
        for <linux-nfs@vger.kernel.org>; Fri, 10 Apr 2015 01:25:24 -0700 (PDT)
Message-ID: <552788F1.4070301@profitbricks.com>
Date: Fri, 10 Apr 2015 10:25:21 +0200
From: Michael Wang <yun.wang@profitbricks.com>
MIME-Version: 1.0
To: "ira.weiny" <ira.weiny@intel.com>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
CC: Doug Ledford <dledford@redhat.com>, Roland Dreier <roland@kernel.org>,
        Sean Hefty <sean.hefty@intel.com>, linux-rdma@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, Hal Rosenstock <hal.rosenstock@gmail.com>,
        Tom Tucker <tom@opengridcomputing.com>,
        Steve Wise <swise@opengridcomputing.com>,
        Hoang-Nam Nguyen <hnguyen@de.ibm.com>,
        Christoph Raisch <raisch@de.ibm.com>,
        Mike Marciniszyn <infinipath@intel.com>, Eli Cohen <eli@mellanox.com>,
        Faisal Latif <faisal.latif@intel.com>,
        Upinder Malhi <umalhi@cisco.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>,
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
        Eric Dumazet <edumazet@google.com>, Erez Shitrit <erezsh@mellanox.com>,
        Tom Gundersen <teg@jklm.no>, Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH v2 01/17] IB/Verbs: Implement new callback query_transport()
 for each HW
References: <5523CCD5.6030401@profitbricks.com> <5523D098.3020007@profitbricks.com> <1428517786.2980.180.camel@redhat.com> <20150408201015.GB28666@obsidianresearch.com> <20150410061610.GA26288@phlsvsds.ph.intel.com>
In-Reply-To: <20150410061610.GA26288@phlsvsds.ph.intel.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/10/2015 08:16 AM, ira.weiny wrote:
> First off there are 2 separate issues here:
> 
> 1) We need to communicate if a port supports or requires various management
>    support from the ib_mad, ib_cm, and/or ib_sa modules.
> 
> 2) We need to communicate how a addresses are formated and resolved for a
>    particular port
> 
> 
> In general I don't think we need to remove all uses of the Transport
> or Link Layer.
> 
> Although we may be able to remove most of the transport uses.
> 
> On Wed, Apr 08, 2015 at 02:10:15PM -0600, Jason Gunthorpe wrote:
[snip]
> 
>>
>> Some of the other checks in this file revolve around pkey, I'm not
>> sure what rocee does there? cap_pkey_supported ?
> 
> It seems IBoE just hardcodes the pkey to 0xffff.  I don't see it used anywhere.
> 
> Function where port requires "real" PKey
> 
> 	-- cma.c: cma_ib_init_qp_attr
> 
> Check rdma_port_req_pkey()?

What about cap_eth_ah() for all the cases need eth addressing handling?

> 
> 
> Over all for the addressing choices:
> 
> The "Transport" (or protocol, or whatever) is Verbs.  The Layer below Verbs
> (OPA/IB/Eth/TCP) defines how addressing, route, and connection information is
> generated, communicated, and used.
> 
> As Jason and Doug have been saying sometimes we want to know when that requires
> SA interaction or the use of the CM protocol (or neither).  Other times we just
> need to know what the Address format or Link Layer is.

Till now it seems like we could be able to eliminate the link layer helper in core
layer, but I'll reserve that helper in next version, if later we do not need it anymore,
let's erase it then ;-)

Regards,
Michael Wang

> 
> 
> Ira
> 
