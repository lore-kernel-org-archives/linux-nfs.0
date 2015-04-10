Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:34989 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753241AbbDJITE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Apr 2015 04:19:04 -0400
Received: by wgyo15 with SMTP id o15so10183149wgy.2
        for <linux-nfs@vger.kernel.org>; Fri, 10 Apr 2015 01:19:03 -0700 (PDT)
Message-ID: <55278774.1070304@profitbricks.com>
Date: Fri, 10 Apr 2015 10:19:00 +0200
From: Michael Wang <yun.wang@profitbricks.com>
MIME-Version: 1.0
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
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
        Eric Dumazet <edumazet@google.com>, Erez Shitrit <erezsh@mellanox.com>,
        Tom Gundersen <teg@jklm.no>, Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH v2 01/17] IB/Verbs: Implement new callback query_transport()
 for each HW
References: <5523CCD5.6030401@profitbricks.com> <5523D098.3020007@profitbricks.com> <1428517786.2980.180.camel@redhat.com> <20150408201015.GB28666@obsidianresearch.com> <552673B0.7040500@profitbricks.com> <20150409160054.GB2035@obsidianresearch.com>
In-Reply-To: <20150409160054.GB2035@obsidianresearch.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/09/2015 06:00 PM, Jason Gunthorpe wrote:
> On Thu, Apr 09, 2015 at 02:42:24PM +0200, Michael Wang wrote:
>> On 04/08/2015 10:10 PM, Jason Gunthorpe wrote:
>> [snip]
>>>
>>> Some of the other checks in this file revolve around pkey, I'm not
>>> sure what rocee does there? cap_pkey_supported ?
>>
>> I'm not sure if this count in capability... how shall we describe it?
> 
> I'm not sure how rocee uses pkey, but maybe the the GRH and pkey thing
> would work well together under a single 'cap_ethernet_ah' ?

Sounds better, we can use this in all the case that handling address
for eth-link-layer :-)

Regards,
Michael Wang

> 
> Jason
> 
