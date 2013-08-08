Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:17609 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752234Ab3HHQV6 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Aug 2013 12:21:58 -0400
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/5] nfs4.1: Initial SP4_MACH_CRED implementation
Date: Thu, 8 Aug 2013 16:21:57 +0000
Message-ID: <8504CA8A-CC32-4BE8-B75D-8F1CAE4D3486@netapp.com>
References: <1375823311-18457-1-git-send-email-dros@netapp.com>
 <20130808155643.GK5282@fieldses.org>
In-Reply-To: <20130808155643.GK5282@fieldses.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Aug 8, 2013, at 11:56 AM, J. Bruce Fields <bfields@fieldses.org> wrote:

> On Tue, Aug 06, 2013 at 05:08:26PM -0400, Weston Andros Adamson wrote:
>> These patches are the initial client-side SP4_MACH_CRED implementation.
>> 
>> Patch 1 is a repost with a few cleanups
>> 
>> Patch 2 adds the sp4 handler that replaces the cred on an rpc message (and
>> picks the right rpc_clnt).  Note that for now, we always use the machine cred
>> if supported - we could only use it if the user cred expires, but this is
>> simple and spec compliant.
> 
> So anything on the spo_may_enforce_list will *always* use the machine
> cred?
> 
> I wonder....  This is within the letter of the spec, but the spec also
> does also give the motivation.  ("The purpose of spo_must_allow is to
> allow clients to solve the following conundrum....")
> 
> I'd worry that server implementors will also stick to the letter of the
> spec and allow this, but also design under the assumption that this is a
> rare case.  (E.g., allow the access but trigger some extra auditing??)
> 
> I'd probably try it this way first too, as you say, it's simpler, but I
> wonder whether it's really what we want to client doing all the time.

OK, I agree.  I'll add that to my current patchset.

> 
>> Patch 3-5 implement SP4_MACH_CRED "features":
>>  - cleanup - CLOSE and LOCKU use machine cred
>>  - secinfo - SECINFO and SECINFO_NO_NAME use machine cred
>>  - stateid - TEST_STATEID and FREE_STATEID use machine cred
>> 
>> There are three more features that I've been working on, but need to be tested
>> before I post:
>>  - commit - COMMIT uses machine cred
>>  - write - WRITE uses machine cred, forces stable writes unless commit feature
>>            is also enabled
>>  - recovery - OPEN and LOCK can use machine cred - only in recovery.
>> 
>> The commit and write cases should be easy to test against a hacked nfsd, but
>> I need to think more about how to test the recovery stuff...
> 
> Can't you just hack nfsd to allow those ops and then do a server
> restart, or try Bryan's fault-injection interface if you want to test
> some more exotic recovery scenario?
> 

Yes - I'm working on testing the client side code now.  Great idea about Bryan's fault injection framework! If I need some extra hooks I'll add them and send patches. 
Also, I've completed testing WRITE and COMMIT against a hacked nfsd and will include this patch in the repost.

-dros

> --b.

