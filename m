Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:38301 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752683AbbC0QRp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2015 12:17:45 -0400
Received: by wibgn9 with SMTP id gn9so37944442wib.1
        for <linux-nfs@vger.kernel.org>; Fri, 27 Mar 2015 09:17:43 -0700 (PDT)
Message-ID: <551582A4.3000501@profitbricks.com>
Date: Fri, 27 Mar 2015 17:17:40 +0100
From: Michael Wang <yun.wang@profitbricks.com>
MIME-Version: 1.0
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
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
        Doug Ledford <dledford@redhat.com>, Eric Dumazet <edumazet@google.com>,
        Erez Shitrit <erezsh@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>,
        Haggai Eran <haggaie@mellanox.com>,
        Shachar Raindel <raindel@mellanox.com>,
        Mike Marciniszyn <mike.marciniszyn@intel.com>,
        Steve Wise <swise@opengridcomputing.com>, Tom Tucker <tom@ogc.us>,
        Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC PATCH 08/11] IB/Verbs: Use management helper has_iwarp()
 for, iwarp-check
References: <551579CA.4030901@profitbricks.com> <55157B98.1060103@profitbricks.com> <20150327161319.GB28412@obsidianresearch.com>
In-Reply-To: <20150327161319.GB28412@obsidianresearch.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/27/2015 05:13 PM, Jason Gunthorpe wrote:
> On Fri, Mar 27, 2015 at 04:47:36PM +0100, Michael Wang wrote:
>> Introduce helper has_iwarp() to help us check if an IB device
>> support IWARP protocol.
> Should probably be !has_rdma_read_sges()
>
> True if the device can handle more than one SGE entry on a RDMA READ
> work request.
Sounds better :-) will change it in next version.

Regards,
Michael Wang

>
> Jason

