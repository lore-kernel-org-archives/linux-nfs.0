Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:35211 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754110AbbDHQFr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Apr 2015 12:05:47 -0400
Received: by widdi4 with SMTP id di4so60796055wid.0
        for <linux-nfs@vger.kernel.org>; Wed, 08 Apr 2015 09:05:46 -0700 (PDT)
Message-ID: <552551D7.80308@profitbricks.com>
Date: Wed, 08 Apr 2015 18:05:43 +0200
From: Michael Wang <yun.wang@profitbricks.com>
MIME-Version: 1.0
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
CC: Tom Talpey <tom@talpey.com>, Roland Dreier <roland@kernel.org>,
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
References: <5523CCD5.6030401@profitbricks.com> <5525132F.1020004@talpey.com> <552521EE.5060206@profitbricks.com> <20150408155145.GA25178@obsidianresearch.com>
In-Reply-To: <20150408155145.GA25178@obsidianresearch.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/08/2015 05:51 PM, Jason Gunthorpe wrote:
> On Wed, Apr 08, 2015 at 02:41:18PM +0200, Michael Wang wrote:
>  
>> I think no one can have the access to all these hardware, so we can
>> only depends on those who accidentally have one to help the testing,
>> but it's still far from that stage..
> 
> I have seen other patches in this style use the compiler to do the
> check, if the patch doesn't change the compiled output then it is
> obviously OK.
> 
> Some careful use of macros might make that possible, but it is a fair
> amount of work.
> 
> However, that may be the only way to get something this invasive
> applied, especially since we've already seen mistakes in the manual
> transforms :|

Make sense, I may be able to testing with mlx4 in our lab, but IMHO
review carefully may be more reliable then incomplete testing in
this case, if we have some tree or branch for next staging, that
could be a good place for public testing, but it's haven't reached
that stage yet ;-)

Regards,
Michael Wang


> 
> Jason
> 
