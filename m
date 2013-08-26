Return-Path: linux-nfs-owner@vger.kernel.org
Received: from p3plsmtpa11-05.prod.phx3.secureserver.net ([68.178.252.106]:40880
	"EHLO p3plsmtpa11-05.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751641Ab3HZNWw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Aug 2013 09:22:52 -0400
Message-ID: <521B56A9.9090003@talpey.com>
Date: Mon, 26 Aug 2013 09:22:49 -0400
From: Tom Talpey <tom@talpey.com>
MIME-Version: 1.0
To: Wendy Cheng <s.wendy.cheng@gmail.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>
Subject: Re: Helps to Decode rpc_debug Output
References: <CABgxfbGFHv2n5=78_irkxXnX9BFDFPzZvqgs_iDn64AR_3cf5w@mail.gmail.com> <520CCDBB.1020501@talpey.com> <CABgxfbFixDTUy4e1EQty86dvNeisG7+hd2QdVSQvv4T2tokFoQ@mail.gmail.com> <CABgxfbH3uA2WzQ2DgOgRrCMhcJ1J6E2NCh13FtDfRzDWje9vWQ@mail.gmail.com>
In-Reply-To: <CABgxfbH3uA2WzQ2DgOgRrCMhcJ1J6E2NCh13FtDfRzDWje9vWQ@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 8/21/2013 11:55 AM, Wendy Cheng wrote:
> On Thu, Aug 15, 2013 at 11:08 AM, Wendy Cheng <s.wendy.cheng@gmail.com> wrote:
>> On Thu, Aug 15, 2013 at 5:46 AM, Tom Talpey <tom@talpey.com> wrote:
>>> On 8/14/2013 8:14 PM, Wendy Cheng wrote:
>>>>
>>>> Longer version of the question:
>>>> I'm trying to enable NFS-RDMA on an embedded system (based on 2.6.38
>>>> kernel) as a client. The IB stacks are taken from OFED 1.5.4. NFS
>>>> server is a RHEL 6.3 Xeon box. The connection uses mellox-4 driver.
>>>> Memory registration is "RPCRDMA_ALLPHYSICAL". There are many issues so
>>>> far but I do manage to get nfs mount working. Simple file operations
>>>> (such as "ls", file read/write, "scp", etc) seem to work as well.
>>>
>
> Yay ... got this up .. amazingly on a uOS that does not have much of
> the conventional kernel debug facilities.

Congrats!

> One thing I'm still scratching my head is that ... by looking at the
> raw IOPS, I don't see dramatic difference between NFS-RDMA vs. NFS
> over IPOIB (TCP).

Sounds like your bottleneck lies in some other component. What's the
storage, for example? RDMA won't do a thing to improve a slow disk.
Or, what kind of IOPS rate are you seeing? If these systems aren't
generating enough load to push a CPU limit, then shifting the protocol
on the same link might not yield much.

> However, the total run time differs greatly. NFS
> over RDMA seems to take a much longer time to finish (vs. NFS over
> IPOIB). Not sure why is that .... Maybe by the constant
> connect/disconnect triggered by reestablish_timeout ? The connection
> re-establish is known to be expensive on this uOS.

Um, yes, of course. Fix that before drawing any conclusions.

Tom.
