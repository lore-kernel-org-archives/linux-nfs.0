Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f42.google.com ([209.85.212.42]:54955 "EHLO
	mail-vb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751519Ab3HUPzu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Aug 2013 11:55:50 -0400
MIME-Version: 1.0
In-Reply-To: <CABgxfbFixDTUy4e1EQty86dvNeisG7+hd2QdVSQvv4T2tokFoQ@mail.gmail.com>
References: <CABgxfbGFHv2n5=78_irkxXnX9BFDFPzZvqgs_iDn64AR_3cf5w@mail.gmail.com>
	<520CCDBB.1020501@talpey.com>
	<CABgxfbFixDTUy4e1EQty86dvNeisG7+hd2QdVSQvv4T2tokFoQ@mail.gmail.com>
Date: Wed, 21 Aug 2013 08:55:49 -0700
Message-ID: <CABgxfbH3uA2WzQ2DgOgRrCMhcJ1J6E2NCh13FtDfRzDWje9vWQ@mail.gmail.com>
Subject: Re: Helps to Decode rpc_debug Output
From: Wendy Cheng <s.wendy.cheng@gmail.com>
To: Tom Talpey <tom@talpey.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 15, 2013 at 11:08 AM, Wendy Cheng <s.wendy.cheng@gmail.com> wrote:
> On Thu, Aug 15, 2013 at 5:46 AM, Tom Talpey <tom@talpey.com> wrote:
>> On 8/14/2013 8:14 PM, Wendy Cheng wrote:
>>>
>>> Longer version of the question:
>>> I'm trying to enable NFS-RDMA on an embedded system (based on 2.6.38
>>> kernel) as a client. The IB stacks are taken from OFED 1.5.4. NFS
>>> server is a RHEL 6.3 Xeon box. The connection uses mellox-4 driver.
>>> Memory registration is "RPCRDMA_ALLPHYSICAL". There are many issues so
>>> far but I do manage to get nfs mount working. Simple file operations
>>> (such as "ls", file read/write, "scp", etc) seem to work as well.
>>

Yay ... got this up .. amazingly on a uOS that does not have much of
the conventional kernel debug facilities.

The hang was caused by auto disconnect, triggered by xprt->timer. The
task was carried out by xprt_init_autodisconnect(). It silently
disconnects the xprt w/out sensible warning. The uOS is on a
small-core (slower) hardware. Instead of a hard number, this timeout
value needs to be at least a "proc" tunable. Will check newer kernels
to see whether it's been improved and/or draft a patch later.

One thing I'm still scratching my head is that ... by looking at the
raw IOPS, I don't see dramatic difference between NFS-RDMA vs. NFS
over IPOIB (TCP). However, the total run time differs greatly. NFS
over RDMA seems to take a much longer time to finish (vs. NFS over
IPOIB). Not sure why is that .... Maybe by the constant
connect/disconnect triggered by reestablish_timeout ? The connection
re-establish is known to be expensive on this uOS. Why do we need two
sets of timeout where
1. xprt->timer disconnects (w/out reconnect) ?
2. reestablish_timeout constantly disconnect/re-connect ?

-- Wendy
