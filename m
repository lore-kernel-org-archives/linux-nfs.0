Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:36211 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751695AbbCaNXD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Mar 2015 09:23:03 -0400
Received: by wixo5 with SMTP id o5so13515147wix.1
        for <linux-nfs@vger.kernel.org>; Tue, 31 Mar 2015 06:23:02 -0700 (PDT)
Message-ID: <551A9FB3.2030903@profitbricks.com>
Date: Tue, 31 Mar 2015 15:22:59 +0200
From: Michael Wang <yun.wang@profitbricks.com>
MIME-Version: 1.0
To: Doug Ledford <dledford@redhat.com>
CC: Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        Ira Weiny <ira.weiny@intel.com>, linux-rdma@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "David S. Miller" <davem@davemloft.net>,
        Or Gerlitz <ogerlitz@mellanox.com>, Moni Shoua <monis@mellanox.com>,
        PJ Waskiewicz <pj.waskiewicz@solidfire.com>,
        Tatyana Nikolova <Tatyana.E.Nikolova@intel.com>,
        Yan Burman <yanb@mellanox.com>,
        Jack Morgenstein <jackm@dev.mellanox.co.il>,
        Bart Van Assche <bvanassche@acm.org>,
        Yann Droneaud <ydroneaud@opteya.com>,
        Colin Ian King <colin.king@canonical.com>,
        Majd Dibbiny <majd@mellanox.com>, Jiri Kosina <jkosina@suse.cz>,
        Matan Barak <matanb@mellanox.com>, Alex Estrin <alex.estrin@intel.com>,
        Eric Dumazet <edumazet@google.com>, Erez Shitrit <erezsh@mellanox.com>,
        Sagi Grimberg <sagig@mellanox.com>, Haggai Eran <haggaie@mellanox.com>,
        Shachar Raindel <raindel@mellanox.com>,
        Mike Marciniszyn <mike.marciniszyn@intel.com>,
        Steve Wise <swise@opengridcomputing.com>, Tom Tucker <tom@ogc.us>,
        Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC PATCH 06/11] IB/Verbs: Use management helper has_sa() and
 cap_sa(), for sa-check
References: <551579CA.4030901@profitbricks.com>		 <55157B43.6060507@profitbricks.com>	 <1427732191.21101.201.camel@redhat.com> <55197CDB.3040105@profitbricks.com> <1427734923.21101.227.camel@redhat.com>
In-Reply-To: <1427734923.21101.227.camel@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/30/2015 07:02 PM, Doug Ledford wrote:
> On Mon, 2015-03-30 at 18:42 +0200, Michael Wang wrote:
>> [snip]
>>
>> rdma_transport_is_ib and rdma_port_ll_is_ib is actually just rough helper
>> to save some code, we can get rid of them when we no longer need them, but
>> currently device driver still using them a lot, I'm not sure if the new
>> mechanism could take cover all these cases...
> [snip]
>
> If we use something like this, then the above is all you need.  Then
> every place in the code that checks for something like has_sa or cap_sa
> can be replaced with rdma_ib_mgmt.  When Ira updates his patches for
> this, he can check for rdma_opa_mgmt to enable jumbo MAD packets and
> whatever else he needs. Every place that does transport == IB and ll ==
> Ethernet can become rdma_transport_is_roce.  Every place that does
> transport == IB and ll == INFINIBAND becomes rdma_transport_is_ib.

Get your point :-) I need to investigate all those cases see if it
works, in case if things unclear, I'll reform it according to my
understanding to adapt to this new mechanism, if there are any
misunderstanding, we can address them case by case during
the review.

>  The
> code in multicast.c just needs to check rdma_ib_mgmt() (which happens to
> make perfect sense anyway as the code in multicast.c that is checking
> that we are on an IB interface is doing so because IB requires extra
> management of the multicast group joins/leaves).

I'll adopt those helpers already been discussed, and they will be
implemented with the helpers from new mechanism
(eg, rdma_ib_mgmt) in next version.

> But, like I said, this
> is an all or nothing change, it isn't something we can ease into.

It's will be great if we can make it, let's see ;-)

Regards,
Michael Wang

>

