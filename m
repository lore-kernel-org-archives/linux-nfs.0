Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:17155 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758734AbaDJRvS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Apr 2014 13:51:18 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: [PATCH V1] NFS-RDMA: fix qp pointer validation checks
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <EE7902D3F51F404C82415C4803930ACD3FDEB3B4@CMEXMB1.ad.emulex.com>
Date: Thu, 10 Apr 2014 13:51:04 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Message-Id: <BD7B05C0-4733-4DD1-83F3-B30B6B0EE48C@oracle.com>
References: <014738b6-698e-4ea1-82f9-287378bfec19@CMEXHTCAS2.ad.emulex.com> <D7AB2150-5F25-4BA2-80D9-94890AD11F8F@primarydata.com> <F1C70AD6-BDD4-4534-8DC4-61D2767581D9@oracle.com> <EE7902D3F51F404C82415C4803930ACD3FDEAA43@CMEXMB1.ad.emulex.com> <E66D006A-0D04-4602-8BF5-6834CACD2E24@oracle.com> <EE7902D3F51F404C82415C4803930ACD3FDEB3B4@CMEXMB1.ad.emulex.com>
To: Devesh Sharma <Devesh.Sharma@Emulex.Com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Apr 10, 2014, at 1:42 PM, Devesh Sharma <Devesh.Sharma@Emulex.Com> wrote:

>> However it seems to me the new (!ia->ri_id->qp) checks outside the connect
>> logic are unnecessary.
>> 
>> Clearly, as you noticed, the ib_post_{send,recv} verbs do not check that their
>> "qp" argument is NULL before dereferencing it.
>> 
>> But I don't understand how xprtrdma can post any operation if the transport
>> isn't connected. In other words, how would it be possible to call
>> rpcrdma_ep_post_recv() if the connect had failed and there was no QP?
>> 
>> If disconnect wipes ia->ri_id->qp while there are still operations in progress,
>> that would be the real bug.
> Yes!, But I have seen one more kernel oops where QP is destroyed and xprtrdma still try to post in LOCAL_INV
> WR on a NULL QP pointer and hence system crashes. So, I think what you missioned is really happening.

I’d like to see the crash data (back trace, etc), if you’ve got it.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



