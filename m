Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48801 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757271Ab0LPUnq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Dec 2010 15:43:46 -0500
Message-ID: <4D0A79FF.3030800@RedHat.com>
Date: Thu, 16 Dec 2010 15:43:43 -0500
From: Steve Dickson <SteveD@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 00/31] NFS XDR clean up for 2.6.38
References: <20101214144747.2293.68070.stgit@matisse.1015granger.net> <4D0A6503.7010901@RedHat.com> <CD110562-AF52-4A2F-BF74-D7ABC4D58D24@oracle.com>
In-Reply-To: <CD110562-AF52-4A2F-BF74-D7ABC4D58D24@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hey Chuck,

On 12/16/2010 03:04 PM, Chuck Lever wrote:
> 
> On Dec 16, 2010, at 2:14 PM, Steve Dickson wrote:
> 
>> Hello,
>>
>> I was wondering if it would be possible hold off on committing major 
>> cleans ups like this one (and the RFC: Split nlm_host cache series) 
>> until pNFS wave3 is committed into either Trond's tree and/or in the
>> mainline kernel. 
>>
>> I realize this is a huge request to make, something we've never done
>> before. But talking with the powers to be on this end, include Ric 
>> Wheeler, accepting these types of patches before the pNFS bits 
>> settle down will make close to impossible for there to be any 
>> meaningful pNFS support in the RHEL 6 kernels. We would have 
>> to push the support off to RHEL 7.
>>
>> The reasoning is this, which I do agree with, these types of 
>> patches, although probably needed, do not added any new features 
>> or fix any outstanding bugs.
> 
> The XDR series does add a new feature, FWIW: it adds buffer overflow
> protection to the client's reply processing logic.  Says so right in the 
> patch descriptions.
No... I didn't miss the "bonus" :-) Its just that these are major changes 
in the  bowels of the NFS code at at time  when other major changes (like pNFS) 
are happening... Its just a lot of change happening at once... 

> 
>> More likely than not (for a time) they will 
>> add some instability due to the lack of usage and testing.  These type of 
>> changes are much too large for even our QE group to test and verify and
>> obviously instability is the last thing we can interject into an 
>> on going enterprise product stream.
> 
> The only NFSv4-related changes in this series are limited to refactoring.  
> No behavior changes are made in the NFSv4 code.  The bulk of the changes 
> effect only NFSv2 and NFSv3, and will have no impact on pNFS (other than 
> a minor API change).
We obviously maintaining stability in those version are important too.. ;-) 
Again its just the amount of change and what is changing... 
    
> 
> XDR is straightforward and well understood.  If anything is broken by these 
> patches, I expect it will be exposed quickly.
> 
> The NLM patches also have nothing to do with pNFS, AFAICT, and can likely 
> be skipped for RHEL 6.
I have found pulling major pieces out of major release tends to have
disastrous results... Its an all or nothing thing... 
 
> 
>> Again, I realize what we are asking and how big this request
>> really is. Its just that we've come so far and are pretty close 
>> (IMHO) to have some meaningful  pNFS support in RHEL 6, I 
>> figured I'd take a shoot and ask... 
> 
> I don't think these are as world-bending as you believe.  I'm happy to 
> discuss the actual changes with Ric.
Fantastic!

steved.
