Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:30408 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753824Ab1EPTWg convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 May 2011 15:22:36 -0400
Subject: Re: 2.6.38.6 - state manager constantly respawns
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4DD1772E.9010609@uw.edu>
Date: Mon, 16 May 2011 15:22:23 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <6A6FB1C3-D4C3-40BE-810A-B4551FA9E591@oracle.com>
References: <4DD16FA8.4030602@uw.edu> <05D08339-888C-4A64-BDC5-8667B3901E7A@oracle.com> <4DD1772E.9010609@uw.edu>
To: Harry Edmon <harry@uw.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On May 16, 2011, at 3:12 PM, Harry Edmon wrote:

> Attached is 1000 lines of output from tshark when the problem is occurring.   The client and server are connected by a private ethernet.

Disappointing: tshark is not telling us the return codes.  However, I see "PUTFH;READ" then "RENEW" in a loop, which indicates the state manager thread is being kicked off because of ongoing difficulties with state recovery.  Is there a stuck application on that client?

Try again with "tshark -V".

> 
> On 05/16/11 11:45, Chuck Lever wrote:
>> On May 16, 2011, at 2:40 PM, Harry Edmon wrote:
>> 
>>   
>>> I have a NFSv4 server and client running 2.6.38.6 with Debian squeeze.  On my client kthreadd is running constantly, and my processes accounting file is full of entries with the PPID of kthreadd and the command being the IP number of the server with "-ma" appended, e.g.
>>> 
>>> 192.168.1.12-ma
>>> 
>>> I believe this is the nfsv4 state manager being constantly being respawned by kthreadd and quickly exiting.   There are no log entries from the state manager (or anything else from NFS).  When I reboot the system with the Debian provided 2.6.32 kernel the problem goes away.  Does anyone have an idea why this would be occurring?   I have included the kernel config file from the client.
>>>     
>> One thing you could do to capture more information about the problem is to run a network trace on a client that is in this state.  The procedures and error codes on the wire might be illuminating.
>> 
>>   
> 
> 
> -- 
> Dr. Harry Edmon			E-MAIL: harry@uw.edu
> 206-543-0547 FAX: 206-543-0308			harry@atmos.washington.edu
> Director of IT, College of the Environment and
> Director of Computing, Dept of Atmospheric Sciences
> University of Washington, Box 351640, Seattle, WA 98195-1640
> 
> <capture_1000.out.gz>

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




