Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from p3plsmtpa08-08.prod.phx3.secureserver.net ([173.201.193.109]:32831
	"EHLO p3plsmtpa08-08.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752898AbbDHLid (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Apr 2015 07:38:33 -0400
Message-ID: <5525132F.1020004@talpey.com>
Date: Wed, 08 Apr 2015 07:38:23 -0400
From: Tom Talpey <tom@talpey.com>
MIME-Version: 1.0
To: Michael Wang <yun.wang@profitbricks.com>,
        Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>,
        linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, netdev@vger.kernel.org
CC: Hal Rosenstock <hal.rosenstock@gmail.com>,
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
References: <5523CCD5.6030401@profitbricks.com>
In-Reply-To: <5523CCD5.6030401@profitbricks.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 4/7/2015 8:25 AM, Michael Wang wrote:
> Mapping List:
> 		node-type	link-layer	old-transport	new-transport
> nes		RNIC		ETH		IWARP		IWARP
> amso1100	RNIC		ETH		IWARP		IWARP
> cxgb3   	RNIC		ETH		IWARP		IWARP
> cxgb4   	RNIC		ETH		IWARP		IWARP
> usnic   	USNIC_UDP	ETH		USNIC_UDP	USNIC_UDP
> ocrdma  	IB_CA		ETH		IB		IBOE
> mlx4    	IB_CA		IB/ETH		IB		IB/IBOE
> mlx5    	IB_CA		IB		IB		IB
> ehca    	IB_CA		IB		IB		IB
> ipath   	IB_CA		IB		IB		IB
> mthca   	IB_CA		IB		IB		IB
> qib     	IB_CA		IB		IB		IB

Can I rewind to ask a high-level question - what's the testing
plan for all of this? Do you have folks lined up for verifying
each of these adapters/networks, and what tests will they run?



