Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:32897 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752778AbbC0Q7b (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2015 12:59:31 -0400
Received: by obvd1 with SMTP id d1so11939276obv.0
        for <linux-nfs@vger.kernel.org>; Fri, 27 Mar 2015 09:59:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150327163219.GD28412@obsidianresearch.com>
References: <551579CA.4030901@profitbricks.com>
	<55157AEB.7020705@profitbricks.com>
	<20150327163219.GD28412@obsidianresearch.com>
Date: Fri, 27 Mar 2015 17:59:30 +0100
Message-ID: <CAJuTgQUGJnbU4k86eQ8G51qr9V5PC9NzQZXf0AbOSdSpVoCFFA@mail.gmail.com>
Subject: Re: [RFC PATCH 04/11] IB/Verbs: Use management helper cap_smi() for smi-check
From: Yun Wang <yun.wang@profitbricks.com>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        Ira Weiny <ira.weiny@intel.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>, linux-nfs@vger.kernel.org,
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
        Doug Ledford <dledford@redhat.com>, Eric Dumazet <edumazet@google.com>,
        Erez Shitrit <erezsh@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>,
        Haggai Eran <haggaie@mellanox.com>,
        Shachar Raindel <raindel@mellanox.com>,
        Mike Marciniszyn <mike.marciniszyn@intel.com>,
        Steve Wise <swise@opengridcomputing.com>, Tom Tucker <tom@ogc.us>,
        Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make sense to me if opa smi will be handled differently, will be
changed in next version :-)

Regards,
Michael Wang

On Fri, Mar 27, 2015 at 5:32 PM, Jason Gunthorpe
<jgunthorpe@obsidianresearch.com> wrote:
> On Fri, Mar 27, 2015 at 04:44:43PM +0100, Michael Wang wrote:
>>
>> Introduce helper cap_smi() to help us check if the port of an
>> IB device support Subnet Management Interface.
>
> This and most of the others should be qualified with 'cap_ib_smi'
> since we already know we will need 'cap_opa_smi' someday
>
> Jason
