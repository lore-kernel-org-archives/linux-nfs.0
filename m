Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:23392 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933808AbcKJPCv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 10 Nov 2016 10:02:51 -0500
Subject: Re: nfs NULL-dereferencing in net-next
To: Olaf Hering <olaf@aepfle.de>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>
References: <20161017201943.64529739@jkicinski-Precision-T1700>
 <DB3PR05MB0764DF28BC53A4A4E78A4DD8ACA80@DB3PR05MB0764.eurprd05.prod.outlook.com>
 <817e43c5-d88d-e616-7074-5715de29d319@Netapp.com>
 <DB3PR05MB0764B39F6EDF851A8A52EBACACAB0@DB3PR05MB0764.eurprd05.prod.outlook.com>
 <20161026190840.3d46dad8@jkicinski-Precision-T1700>
 <0ab5021c-84eb-cb9f-c7f5-4d856fdb0f4b@Netapp.com>
 <DB3PR05MB0764F0409AE75E0172ABFE2EACAA0@DB3PR05MB0764.eurprd05.prod.outlook.com>
 <20161031152550.10acb7e0@jkicinski-Precision-T1700>
 <e80aa023-b8e3-c663-1ef4-110f8a1368ab@Netapp.com>
 <20161110144721.GA30540@aepfle.de>
CC: Jakub Kicinski <kubakici@wp.pl>, Yotam Gigi <yotamg@mellanox.com>,
        "Andy Adamson" <andros@Netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Yotam Gigi <yotam.gi@gmail.com>, mlxsw <mlxsw@mellanox.com>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Message-ID: <512b06f0-31a6-f397-d618-bd2e7b79c06b@Netapp.com>
Date: Thu, 10 Nov 2016 10:02:41 -0500
MIME-Version: 1.0
In-Reply-To: <20161110144721.GA30540@aepfle.de>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/10/2016 09:47 AM, Olaf Hering wrote:
> On Thu, Nov 03, Anna Schumaker wrote:
> 
>> Aww, I was hoping that patch would work.  It still seemed to fix some
>> issues for me when mounting multiple servers, so I'm planning to keep
>> it.  Unfortunately I'm out of town this week, so I haven't had much of
>> a chance to keep poking at this issue.  I should be able to get back
>> to it next week!
> 
> Is this supposed to be fixed already? I get an oops in
> rpc_clnt_xprt_switch_has_addr+0xc/0x40 with 4.9.0-rc4.

Not yet, sorry.  I'm waiting on one bugfix patch before sending my pull request.

Thanks for waiting patiently,
Anna

> 
> Olaf
> 

