Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:37227 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753792AbbDJHqw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Apr 2015 03:46:52 -0400
Received: by wiaa2 with SMTP id a2so16467748wia.0
        for <linux-nfs@vger.kernel.org>; Fri, 10 Apr 2015 00:46:51 -0700 (PDT)
Message-ID: <55277FE8.50107@profitbricks.com>
Date: Fri, 10 Apr 2015 09:46:48 +0200
From: Michael Wang <yun.wang@profitbricks.com>
MIME-Version: 1.0
To: Doug Ledford <dledford@redhat.com>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
CC: Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>,
        linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
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
References: <5523CCD5.6030401@profitbricks.com>	 <5523D098.3020007@profitbricks.com> <1428517786.2980.180.camel@redhat.com>	 <20150408201015.GB28666@obsidianresearch.com>	 <1428590070.2980.190.camel@redhat.com>	 <20150409160123.GA31353@obsidianresearch.com> <1428614348.2980.287.camel@redhat.com>
In-Reply-To: <1428614348.2980.287.camel@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/09/2015 11:19 PM, Doug Ledford wrote:
[snip]
>>
>> I've written this before: The mess here is that it is too hard to know
>> what the call sites are actually checking for when it is some baroque
>> conditional.
> 
> The two goals: being specific about what the test is returning and
> minimizing the bitmap footprint; are not necessarily opposed.  One can
> do both at the same time.

This could be internal reforming after the cap_XX() stuff works for core
layer, at that time we don't need to touch core layer anymore, just
introducing this bitmap stuff in verb layer, replacing the implementation
of these helpers with the bitmap check, and following the semantic (description).

Regards,
Michael Wang

> 
