Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:35861 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752098AbbDMHkU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Apr 2015 03:40:20 -0400
Received: by wgsk9 with SMTP id k9so71278004wgs.3
        for <linux-nfs@vger.kernel.org>; Mon, 13 Apr 2015 00:40:18 -0700 (PDT)
Message-ID: <552B72DF.2080600@profitbricks.com>
Date: Mon, 13 Apr 2015 09:40:15 +0200
From: Michael Wang <yun.wang@profitbricks.com>
MIME-Version: 1.0
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Doug Ledford <dledford@redhat.com>
CC: "ira.weiny" <ira.weiny@intel.com>, Roland Dreier <roland@kernel.org>,
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
References: <5523CCD5.6030401@profitbricks.com> <5523D098.3020007@profitbricks.com> <1428517786.2980.180.camel@redhat.com> <20150410074805.GA11855@phlsvsds.ph.intel.com> <1428685843.2980.353.camel@redhat.com> <20150410173650.GB26419@obsidianresearch.com>
In-Reply-To: <20150410173650.GB26419@obsidianresearch.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/10/2015 07:36 PM, Jason Gunthorpe wrote:
> On Fri, Apr 10, 2015 at 01:10:43PM -0400, Doug Ledford wrote:
> 
>> documented.  I get why you link the address variant, because it pops out
>> all the things that are special about IBoE addressing and calls out that
>> the issues need to be handled.  However, saying requires_iboe_addr(),
>> while foreshadowing the work that needs done, doesn't actually document
>> the work that needs done.  Whether we call is dev_is_iboe() or
>> requires_iboe_addr(), it would be good if the documentation spelled out
>> those specific requirements for reference sake.
> 
> My deep hope for this, was that the test 'requires_iboe_addr' or
> whatever we call it would have a *really good* kdoc.
> 
> List all the ways iboe_addr's work, how they differ from IB addresses,
> refer to the specs people should read to understand it, etc.
> 
> The patches don't do this, and maybe Michael is the wrong person to
> fill that in, but we can get it done..

That's exactly what I'm thinking ;-)

At first I'm just trying to save us some code but now it's becoming
a topic far above that purpose, I'd like to help commit whatever we already
settled and pass the internal reforming works to experts like you guys
, implement the bitmask stuff ;-)

And I can still help on review and may be testing with mlx4 if later I
got the access.

> 
> Jason
> 
> BTW: Michael, next time you post the series, please trim the CC
> list...

Thanks for the remind, I'll do trim in v3 :-)

Regards,
Michael Wang

> 
