From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Possible bug in nfs-utils source.
Date: Wed, 04 Mar 2009 17:59:18 -0500
Message-ID: <49AF07C6.7030003@RedHat.com>
References: <4977A0EC.3050103@candelatech.com> <2055BE67-5060-4D4E-BB0A-A8E61152A2EC@oracle.com> <4977B71B.4030003@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:57352 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752509AbZCDXCA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Mar 2009 18:02:00 -0500
In-Reply-To: <4977B71B.4030003@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Ben Greear wrote:
> Chuck Lever wrote:
>> On Jan 21, 2009, at Jan 21, 2009, 5:25 PM, Ben Greear wrote:
>>> I'm working on adding support to bind to local addresses, and
>>> I noticed this code in nfs/getport.c
>>>
>>> I believe the sizeof should probably be sizeof(*lb_addr) ?
>>
>> Yes.  Can you submit a patch to Steve and copy the list?
> 
> 
> The patch is attached.
> 
> Signed-Off-By:  Ben Greear <greearb@candelatech.com>
Committed... 

steved.
