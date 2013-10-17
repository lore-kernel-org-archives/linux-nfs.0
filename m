Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e36.co.us.ibm.com ([32.97.110.154]:58506 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758653Ab3JQSXy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Oct 2013 14:23:54 -0400
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <cvogan@us.ibm.com>;
	Thu, 17 Oct 2013 12:23:53 -0600
In-Reply-To: <52602835.4000701@candelatech.com>
References: <525D899F.5010604@candelatech.com>  <52601FED.6070708@candelatech.com> <1382033137.3216.3.camel@leira.trondhjem.org> <52602835.4000701@candelatech.com>
To: Ben Greear <greearb@candelatech.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-nfs-owner@vger.kernel.org
MIME-Version: 1.0
Subject: Re: 'umount -f /mnt/foo' fails if server IP is gone.
Message-ID: <OF4478D077.E0CFC3EE-ON87257C07.0064D9E3-86257C07.00650BD4@us.ibm.com>
From: Christopher T Vogan <cvogan@us.ibm.com>
Date: Thu, 17 Oct 2013 13:23:49 -0500
Content-Type: text/plain; charset="US-ASCII"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I have reported 2 scenarios related to this issue, the second topic being 
more relevant to your problem.
vfs: allow umount to handle mountpoints without revalidating them
and
NFSERR_STALE on umount with 3.10.0.RC5 kernel


Christopher Vogan
NFS Development & Test



From:   Ben Greear <greearb@candelatech.com>
To:     "Myklebust, Trond" <Trond.Myklebust@netapp.com>, 
Cc:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date:   10/17/2013 01:14 PM
Subject:        Re: 'umount -f /mnt/foo' fails if server IP is gone.
Sent by:        linux-nfs-owner@vger.kernel.org



On 10/17/2013 11:05 AM, Myklebust, Trond wrote:
> On Thu, 2013-10-17 at 10:35 -0700, Ben Greear wrote:
>> On 10/15/2013 11:29 AM, Ben Greear wrote:
>>> Is 'umount -f' supposed to always work, even if the file server
>>> goes away?
>>>
>>> I have a user's system that just hangs forever in this case.
>>>
>>> Could be local changes we have made, but I'm curious about
>>> the expected behaviour before I go digging too deep...
>>
>> Any input on this?  I don't mind trying to fix it, but I
>> would like to know how it is supposed to work.
> 
> 'umount -f' has always been iffy. It just kills any pending RPC calls
> _before_ trying to unmount. Since the unmount itself can trigger
> writeback flushes (and hence more RPC calls), the trace you are seeing
> is indeed possible.

I tried 'umount -f -l', and that also does not work.

Any ideas on how to fix this properly?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html



