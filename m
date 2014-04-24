Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f52.google.com ([74.125.82.52]:49559 "EHLO
	mail-wg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750860AbaDXHM5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Apr 2014 03:12:57 -0400
Received: by mail-wg0-f52.google.com with SMTP id b13so625167wgh.23
        for <linux-nfs@vger.kernel.org>; Thu, 24 Apr 2014 00:12:56 -0700 (PDT)
Message-ID: <5358B975.4020207@dev.mellanox.co.il>
Date: Thu, 24 Apr 2014 10:12:53 +0300
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
MIME-Version: 1.0
To: Devesh Sharma <Devesh.Sharma@Emulex.Com>,
        Chuck Lever <chuck.lever@oracle.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH V1] NFS-RDMA: fix qp pointer validation checks
References: <014738b6-698e-4ea1-82f9-287378bfec19@CMEXHTCAS2.ad.emulex.com> <D7AB2150-5F25-4BA2-80D9-94890AD11F8F@primarydata.com> <F1C70AD6-BDD4-4534-8DC4-61D2767581D9@oracle.com> <EE7902D3F51F404C82415C4803930ACD3FDEAA43@CMEXMB1.ad.emulex.com> <E66D006A-0D04-4602-8BF5-6834CACD2E24@oracle.com> <EE7902D3F51F404C82415C4803930ACD3FDEB3B4@CMEXMB1.ad.emulex.com> <BD7B05C0-4733-4DD1-83F3-B30B6B0EE48C@oracle.com> <EE7902D3F51F404C82415C4803930ACD3FDEB3DF@CMEXMB1.ad.emulex.com> <56C87770-7940-4006-948C-FEF3C0EC4ACC@oracle.com> <EE7902D3F51F404C82415C4803930ACD3FDEBD66@CMEXMB1.ad.emulex.com> <5710A71F-C4D5-408B-9B41-07F21B5853F0@oracle.com> <6837A427-B677-4CC7-A022-4FB9E52A3FC6@oracle.com> <EE7902D3F51F404C82415C4803930ACD3FDED915@CMEXMB1.ad.emulex.com> <C689AB91-46F6-4E96-A673-0DE76FE54CC4@oracle.com> <EE7902D3F51F404C82415C4803930ACD3FDEE11F@CMEXMB1.ad.emulex.com> <1bab6615-60c4-4865-a6a0-c53bb1c32341@CMEXHTCAS1.ad.emulex.com>
In-Reply-To: <1bab6615-60c4-4865-a6a0-c53bb1c32341@CMEXHTCAS1.ad.emulex.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 4/24/2014 2:30 AM, Devesh Sharma wrote:
> Hi Chuck
>
> Following is the complete call trace of a typical NFS-RDMA transaction while mounting a share.
> It is unavoidable to stop calling post-send in case it is not created. Therefore, applying checks to the connection state is a must
> While registering/deregistering frmrs on-the-fly. The unconnected state of QP implies don't call  post_send/post_recv from any context.
>

Long thread... didn't follow it all.

If I understand correctly this race comes only for *cleanup* (LINV) of 
FRMR registration while teardown flow destroyed the QP.
I think this might be disappear if for each registration you post LINV+FRMR.
This is assuming that a situation where trying to post Fastreg on a 
"bad" QP can
never happen (usually since teardown flow typically suspends outgoing 
commands).

Sagi.
