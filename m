From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH][nfs-utils] configuration: Fix a typo in configure.ac
Date: Mon, 01 Mar 2010 09:13:17 -0500
Message-ID: <4B8BCB7D.1030202@RedHat.com>
References: <1266709510.3507.1.camel@localhost.localdomain> <20100222182202.GB11356@fieldses.org> <4B8BB9B8.8040703@RedHat.com> <20100301132554.GA17054@fieldses.org> <4B8BC5B9.1020304@RedHat.com> <20100301135534.GA17660@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12325 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751174Ab0CAONU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Mar 2010 09:13:20 -0500
In-Reply-To: <20100301135534.GA17660@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/01/2010 08:55 AM, J. Bruce Fields wrote:
> On Mon, Mar 01, 2010 at 08:48:41AM -0500, Steve Dickson wrote:
>> On 03/01/2010 08:25 AM, J. Bruce Fields wrote:
>>> On Mon, Mar 01, 2010 at 07:57:28AM -0500, Steve Dickson wrote:
>>>> On 02/22/2010 01:22 PM, J. Bruce Fields wrote:
>>>>> On Sat, Feb 20, 2010 at 03:45:10PM -0800, Trond Myklebust wrote:
>>>>>> From: Trond Myklebust <Trond.Myklebust@netapp.com>
>>>>>>
>>>>>> Fix a typo in commit 6d5ac3fa (nfsd: Disble NFS 4.1 functionality by default).
>>>>>
>>>>> Better: please just rever 6d5ac3fa and apply
>>>>> http://marc.info/?l=linux-nfs&m=126540028610022&w=2
>>>> The problem I saw with the this patch was it would take 
>>>> a code change to re-enable the 4.1 functional,
>>>
>>> Enabling 4.1 will require no code changes to nfs-utils, only to the
>>> kernel.  (But it will require a lot of code changes to nfs-utils, as we
>>> should complete 4.1 support first.)
>>>
>>>> verses a
>>>> enabling a configuration flag. Plus, there has been a 
>>>> precedence set of having these types of configuration flags,
>>>> note the enable_nfsv3, enable_nfsv4, so adding a enable_nfsv41
>>>> seem to me made sense...
>>>>
>>>>>
>>>>> 	- distributions shouldn't be turning on 4.1 by default yet.
>>>> Its not... If the --enable_nfsv41 is not set, the 4.1 functional is
>>>> off. Having this type of flag enables the distros to enable the
>>>> functionality on development kernels but disable it on stable 
>>>
>>> So you want to enable it (for example) in Fedora, but disable it in
>>> RHEL?
>> No, its only enabled in Rawhide which is the untested/developmental 
>> version of the next fedora release (in this case F14). When F14 is ready,
>> the determination will be made (with solicited input) if the 4.1 code
>> should continue to be enabled or disabled.
> 
> That decision should depend on whether the kernel 4.1 support is
> complete or not.  If it is, then the kernel will default 4.1 on, and
> there will be no need for an nfs-utils change.
> 
>> This is why I like the configuration switch. There is no code
>> changes, code is just being disabled. Which, in theory, should have
>> no ramification at all..    
>>
>>>
>>> I don't think that's a good idea.  If servers running current Fedora
>>> kernels are still around when the client starts trying 4.1 first, then
>>> we'll run into trouble.
>> Since people actually have to specify the -o minorversion=1 mount
>> option (which is not documented, btw), I'm going to assume those people
>> know what they are doing and probably will know how to fix any problems 
>> that may arise... 
> 
> No, that's not enough.  They may be accessing the server through other
> clients.
Understood... just curious, would you happen to know of any clients
that use 4.1 as the default? Was there any at this year's Connectathon?

> 
> We need users to make a conscious decision to turn on the server-side.
> It's not enough to do it only on the client side.
Right. At this point people will either have to recompile nfs-utils using
the --enable-nfsv41 flag or edit their initscript and do the echo trick... 
So isn't having to do one of the above be construed as conscious decision?

steved.
