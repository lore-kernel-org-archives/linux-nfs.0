Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:54733 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753659AbbDHPwL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Apr 2015 11:52:11 -0400
Date: Wed, 8 Apr 2015 09:51:45 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: Michael Wang <yun.wang@profitbricks.com>
Cc: Tom Talpey <tom@talpey.com>, Roland Dreier <roland@kernel.org>,
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
        Doug Ledford <dledford@redhat.com>, Eric Dumazet <edumazet@google.com>,
        Erez Shitrit <erezsh@mellanox.com>, Tom Gundersen <teg@jklm.no>,
        Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH v2 00/17] IB/Verbs: IB Management Helpers
Message-ID: <20150408155145.GA25178@obsidianresearch.com>
References: <5523CCD5.6030401@profitbricks.com>
 <5525132F.1020004@talpey.com>
 <552521EE.5060206@profitbricks.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <552521EE.5060206@profitbricks.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 08, 2015 at 02:41:18PM +0200, Michael Wang wrote:
 
> I think no one can have the access to all these hardware, so we can
> only depends on those who accidentally have one to help the testing,
> but it's still far from that stage..

I have seen other patches in this style use the compiler to do the
check, if the patch doesn't change the compiled output then it is
obviously OK.

Some careful use of macros might make that possible, but it is a fair
amount of work.

However, that may be the only way to get something this invasive
applied, especially since we've already seen mistakes in the manual
transforms :|

Jason
