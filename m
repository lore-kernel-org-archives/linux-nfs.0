Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:33328 "EHLO
	mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753445AbbC0Rf3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2015 13:35:29 -0400
Received: by oifl3 with SMTP id l3so82057588oif.0
        for <linux-nfs@vger.kernel.org>; Fri, 27 Mar 2015 10:35:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150327171631.GC27862@phlsvsds.ph.intel.com>
References: <551579CA.4030901@profitbricks.com>
	<55157B98.1060103@profitbricks.com>
	<20150327161319.GB28412@obsidianresearch.com>
	<20150327171631.GC27862@phlsvsds.ph.intel.com>
Date: Fri, 27 Mar 2015 18:35:28 +0100
Message-ID: <CAJuTgQUFXLdaj=+6baamUvPHC4Ocj4f_U6Q5WD9UijbaZ3iYLg@mail.gmail.com>
Subject: Re: [RFC PATCH 08/11] IB/Verbs: Use management helper has_iwarp()
 for, iwarp-check
From: Yun Wang <yun.wang@profitbricks.com>
To: "ira.weiny" <ira.weiny@intel.com>
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
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

On Fri, Mar 27, 2015 at 6:16 PM, ira.weiny <ira.weiny@intel.com> wrote:
> On Fri, Mar 27, 2015 at 10:13:19AM -0600, Jason Gunthorpe wrote:
>> On Fri, Mar 27, 2015 at 04:47:36PM +0100, Michael Wang wrote:
>> >
>> > Introduce helper has_iwarp() to help us check if an IB device
>> > support IWARP protocol.
>>
>> Should probably be !has_rdma_read_sges()
>>
>> True if the device can handle more than one SGE entry on a RDMA READ
>> work request.
>
> Isn't this value already provided by the query_device verb?
>
> The verbs spec states the Query HCA contains the:
>
> "Maximum number of scatter/gather entries per Work Request supported by the
> HCA."

I'm not sure but may be query_device() is just too expensive for this path?
I need some investigation here too.

Regards,
Michael Wang

>
> -- Ira
>
>>
>> Jason
