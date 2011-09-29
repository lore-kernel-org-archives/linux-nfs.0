Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:15421 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753178Ab1I2SPU convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Sep 2011 14:15:20 -0400
Subject: Re: [RFC V2 0/1] SUNRPC: dynamic rpc_slot allocator
Content-Type: text/plain; charset=us-ascii
From: Andy Adamson <andros@netapp.com>
In-Reply-To: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B54E9B2@SACMVEXC2-PRD.hq.netapp.com>
Date: Thu, 29 Sep 2011 14:15:18 -0400
Cc: "Harshula" <harshula@redhat.com>,
        "Adamson, Andy" <William.Adamson@netapp.com>, <jlayton@redhat.com>,
        <linux-nfs@vger.kernel.org>
Message-Id: <BCDBCAF0-372A-4ABD-8139-C1A4C4D0E8AE@netapp.com>
References: <1305059200-412-1-git-send-email-andros@netapp.com> <1317179295.2609.2.camel@serendib> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B54E9B2@SACMVEXC2-PRD.hq.netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Sep 27, 2011, at 11:24 PM, Myklebust, Trond wrote:

>> -----Original Message-----
>> From: Harshula [mailto:harshula@redhat.com]
>> Sent: Tuesday, September 27, 2011 11:08 PM
>> To: Adamson, Andy
>> Cc: Myklebust, Trond; jlayton@redhat.com; linux-nfs@vger.kernel.org
>> Subject: Re: [RFC V2 0/1] SUNRPC: dynamic rpc_slot allocator
>> 
>> Hi Andy,
>> 
>> What's the status of your dynamic slot allocator patch?
> 
> Andy is still doing performance measurements to verify the effectiveness on high bandwidth+high latency networks, but the latest version of those patches has already been merged upstream. Please see
> 
> git log -p f85ef69..34006ce
> 
> on a recent pull from Linus.
> 
> Note that we still need further patches in order to grow the NFSv4.1 session as the TCP window expands, but the above set of patches should at least ensure that the number of sunrpc slots can continue to keep up.

I'm looking into the v4.1 session slot management ....

-->Andy

> 
> Cheers
>   Trond

