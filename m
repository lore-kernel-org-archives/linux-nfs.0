Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ve0-f180.google.com ([209.85.128.180]:62053 "EHLO
	mail-ve0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756045Ab3HOSIq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Aug 2013 14:08:46 -0400
MIME-Version: 1.0
In-Reply-To: <520CCDBB.1020501@talpey.com>
References: <CABgxfbGFHv2n5=78_irkxXnX9BFDFPzZvqgs_iDn64AR_3cf5w@mail.gmail.com>
	<520CCDBB.1020501@talpey.com>
Date: Thu, 15 Aug 2013 11:08:45 -0700
Message-ID: <CABgxfbFixDTUy4e1EQty86dvNeisG7+hd2QdVSQvv4T2tokFoQ@mail.gmail.com>
Subject: Re: Helps to Decode rpc_debug Output
From: Wendy Cheng <s.wendy.cheng@gmail.com>
To: Tom Talpey <tom@talpey.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 15, 2013 at 5:46 AM, Tom Talpey <tom@talpey.com> wrote:
> On 8/14/2013 8:14 PM, Wendy Cheng wrote:
>>
>> Longer version of the question:
>> I'm trying to enable NFS-RDMA on an embedded system (based on 2.6.38
>> kernel) as a client. The IB stacks are taken from OFED 1.5.4. NFS
>> server is a RHEL 6.3 Xeon box. The connection uses mellox-4 driver.
>> Memory registration is "RPCRDMA_ALLPHYSICAL". There are many issues so
>> far but I do manage to get nfs mount working. Simple file operations
>> (such as "ls", file read/write, "scp", etc) seem to work as well.
>
[snip]

> Why did you replace the Linux IB stack with OFED? Did you also take the
> NFS/RDMA from that package, and if so are you sure that it all is
> is working properly? Doesn't 2.6.38 already have all this?
>

Other part of the cluster runs OFED 1.5.4 on top of RHEL 6.3 - it was
a product decision. Ditto for the 2.6.38 based uOS.

OFED 1.5.4 based NFS/RDMA (i.e. xprtrdma) does not run on both
platforms. It took a while to understand the setup. I believe issues
with RHEL boxes have been fixed - at least iozone runs thru (as client
and server) w/out trouble. Now the issue is with this 2.6.38 uOS (as
client) that talks to RHEL 6.3 (as server). I don't know much about
NFS V4 so the focus is on V3.

-- Wendy
