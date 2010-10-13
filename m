Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49456 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753563Ab0JMXT7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Oct 2010 19:19:59 -0400
Message-ID: <4CB63E81.9010100@RedHat.com>
Date: Wed, 13 Oct 2010 19:19:29 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: whither NFS umount?
References: <678C897C-DECE-49C1-AFC4-B57CF3A09385@oracle.com>	<1286903046.24878.13.camel@heimdal.trondhjem.org>	<C5614601-A685-4D7A-8DC3-23375F88AF42@oracle.com>	<20101012151826.76b75f52@corrin.poochiereds.net>	<1286912649.1956.19.camel@heimdal.trondhjem.org>	<4CB5EF15.5030003@RedHat.com>	<20101013141317.66f23906@corrin.poochiereds.net>	<4CB5FE65.3090409@RedHat.com> <20101013145601.468acc2a@corrin.poochiereds.net> <4CB6090F.60301@RedHat.com> <E22DAFE2-A677-4D91-8976-5F641141DD36@oracle.com>
In-Reply-To: <E22DAFE2-A677-4D91-8976-5F641141DD36@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hey... 

On 10/13/2010 04:47 PM, Chuck Lever wrote:
> 
> On Oct 13, 2010, at 3:31 PM, Steve Dickson wrote:
> 
>> On 10/13/2010 02:56 PM, Jeff Layton wrote:
>>> On Wed, 13 Oct 2010 14:45:57 -0400
>>> Steve Dickson <SteveD@redhat.com> wrote:
>>>
>>>> I would say send the UMNT, since it does not cause any pain to send it
>>>> verses the pain that could be cause by not sending it...
>>>>
>>>> This is a perfect example of fixing something that is not
>>>> broken... We can put our energy in better place that worrying
>>>> about things like this... IMHO...
>>>
>>> But it *is* broken. As Chuck pointed out, the main problem is that mtab
>>> handling is broken on remounts. That's a real problem that needs to be
>>> fixed.
>> Fine... Lets just focus on that issue...  
> 
> Actually...
> 
> Removing UMNT support _is_ the proposed fix for the "-o remount" issue.  
> The reason we depend on /etc/mtab is because umount needs to know how to do 
> the unmount.  
I'm in the middle of testing one of your patches that that uses /proc/mounts
to figure out how to unmount things... Which I think is the correct way
to do it... Breaking our dependence on /etc/mtab is a good thing... IMHO...
 
> A "-o remount" wipes that information.  It turns out that 
> there is no correct implementation of remount rewriting the options in /etc/mtab.
> utils-linux-ng does not even get this right, and mount(8) claims 
> that /etc/mtab will not be reliable after a remount.
Another reason for us to move away from /etc/mtab... 

> 
> If we no longer have to perform a UMNT, then there is no need to worry about
> the contents of /etc/mtab, for any reason, and it can go away.  I believe we 
> are the only file system that is holding up the complete removal of /etc/mtab.
I guess don't understand the justification of not send an industry
wide accepted and expected protocol message because we have bug in our 
code... Is a protocol message every single NFS client sends and
has sent for many many years... Now we are not going adhere to this
industry practice because we don't think its necessary since it 
will make things hard for us to fix bug? 

Lets try to fix this  bug in least disruptive way? A way that does not 
change an industry common practice...
 
> 
> I think there's no reason to keep UMNT in user space; it simply can never 
> work correctly there.  I believe a kernel space implementation would be 
> simple, and would work correctly much more often than user space UMNT does now.
> I don't agree with Trond that we should not do it there, but that's an argument 
> I can't win.
I can understand the reasoning... As you know I'm always in favour of
keeping things in user space because its always easier updated a user 
packages than a kernel... 
 
> 
>>> I agree that our time is better spent elsewhere. I just think that we
>>> ought to make that happen by eliminating the unnecessary umount helper.
>>> The less code that we need to maintain, the better...
>> In general I agree... but removing functionality (i.e. umount.nfs)
>> can cause more pain than just leaving things as is...
> 
> Is there any specific evidence that there will be pain if umount.nfs is removed? 
> I can't think of any use case it would harm.  It's already broken in many cases,
> and we have never heard of a specific application complaint about it.  If there 
> had been a complaint we would have fixed it already.  UMNT is clearly vestigial.
No I do not any evidence.... its just pure paranoia in the fact we will
could easily break third party applications that will depend on the 
existence of that binary... Plus removing the binary is simply not needed
to fix a bug in the processing of /etc/mtab... Its just overkill... IMHO...

I'll take a look and see if I can come up with a way to fixing the remount
bug without remove the umount.nfs binary as well as continuing to
send out the UMNT message... It has to be possible... 

steved.

