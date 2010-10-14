Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:27739 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754881Ab0JNPaY convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Oct 2010 11:30:24 -0400
Subject: Re: whither NFS umount?
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4CB63E81.9010100@RedHat.com>
Date: Thu, 14 Oct 2010 11:29:26 -0400
Cc: Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <1BC33C94-1C91-42BE-8FC1-5F85E0D6FABD@oracle.com>
References: <678C897C-DECE-49C1-AFC4-B57CF3A09385@oracle.com>	<1286903046.24878.13.camel@heimdal.trondhjem.org>	<C5614601-A685-4D7A-8DC3-23375F88AF42@oracle.com>	<20101012151826.76b75f52@corrin.poochiereds.net>	<1286912649.1956.19.camel@heimdal.trondhjem.org>	<4CB5EF15.5030003@RedHat.com>	<20101013141317.66f23906@corrin.poochiereds.net>	<4CB5FE65.3090409@RedHat.com> <20101013145601.468acc2a@corrin.poochiereds.net> <4CB6090F.60301@RedHat.com> <E22DAFE2-A677-4D91-8976-5F641141DD36@oracle.com> <4CB63E81.9010100@RedHat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Oct 13, 2010, at 7:19 PM, Steve Dickson wrote:

> Hey... 
> 
> On 10/13/2010 04:47 PM, Chuck Lever wrote:
>> 
>> On Oct 13, 2010, at 3:31 PM, Steve Dickson wrote:
>> 
>>> On 10/13/2010 02:56 PM, Jeff Layton wrote:
>>>> On Wed, 13 Oct 2010 14:45:57 -0400
>>>> Steve Dickson <SteveD@redhat.com> wrote:
>>>> 
>>>>> I would say send the UMNT, since it does not cause any pain to send it
>>>>> verses the pain that could be cause by not sending it...
>>>>> 
>>>>> This is a perfect example of fixing something that is not
>>>>> broken... We can put our energy in better place that worrying
>>>>> about things like this... IMHO...
>>>> 
>>>> But it *is* broken. As Chuck pointed out, the main problem is that mtab
>>>> handling is broken on remounts. That's a real problem that needs to be
>>>> fixed.
>>> Fine... Lets just focus on that issue...  
>> 
>> Actually...
>> 
>> Removing UMNT support _is_ the proposed fix for the "-o remount" issue.  
>> The reason we depend on /etc/mtab is because umount needs to know how to do 
>> the unmount.  
> I'm in the middle of testing one of your patches that that uses /proc/mounts
> to figure out how to unmount things... Which I think is the correct way
> to do it... Breaking our dependence on /etc/mtab is a good thing... IMHO...
> 
>> A "-o remount" wipes that information.  It turns out that 
>> there is no correct implementation of remount rewriting the options in /etc/mtab.
>> utils-linux-ng does not even get this right, and mount(8) claims 
>> that /etc/mtab will not be reliable after a remount.
> Another reason for us to move away from /etc/mtab...

Using /proc/mounts to determine whether a mount point is NFSv4 or NFS is OK.

However, /proc/mounts doesn't contain the original mount options used to negotiate the mount.  Ideally, we want to use the original mount command line options, and not the exact options that were negotiated, when doing the umount.

The example I use to explain why /proc/mounts is not appropriate is a simple mount "vers=3".  It negotiates with the server and discovers the mount service is on port 4545.  The mount proceeds.  After a while the server reboots, and puts the mount service on port 32769.  Our /proc/mounts still has "mountport=4545" since that's what was negotiated at mount time and passed to the kernel.  When umount tries the UMNT request, it will read /proc/mounts, send the UMNT request to port 4545, and fail.

Now, we could just say "screw it" and use the negotiated options rather than the user-specified ones.  But that means there are still cases we could perform the UMNT correctly which would not work.

Another choice would be to store the original NFS-related command line mount options somewhere other than /etc/mtab, and leave them alone during a remount.  If we can't perform UMNT in the kernel, I'd prefer this type of solution to either updating /etc/mtab on a remount or using /proc/mounts during umount.

How about a file under /var/lib/nfs ?

>> If we no longer have to perform a UMNT, then there is no need to worry about
>> the contents of /etc/mtab, for any reason, and it can go away.  I believe we 
>> are the only file system that is holding up the complete removal of /etc/mtab.
> I guess don't understand the justification of not send an industry
> wide accepted and expected protocol message because we have bug in our 
> code... Is a protocol message every single NFS client sends and
> has sent for many many years... Now we are not going adhere to this
> industry practice because we don't think its necessary since it 
> will make things hard for us to fix bug? 

I'm sympathetic to that, though I also agree with Trond that UMNT is probably not relevant these days.  Since it is so unreliable, I think most implementations avoid depending on it for anything.

> Lets try to fix this  bug in least disruptive way? A way that does not 
> change an industry common practice...
> 
>> 
>> I think there's no reason to keep UMNT in user space; it simply can never 
>> work correctly there.  I believe a kernel space implementation would be 
>> simple, and would work correctly much more often than user space UMNT does now.
>> I don't agree with Trond that we should not do it there, but that's an argument 
>> I can't win.
> I can understand the reasoning... As you know I'm always in favour of
> keeping things in user space because its always easier updated a user 
> packages than a kernel... 
> 
>> 
>>>> I agree that our time is better spent elsewhere. I just think that we
>>>> ought to make that happen by eliminating the unnecessary umount helper.
>>>> The less code that we need to maintain, the better...
>>> In general I agree... but removing functionality (i.e. umount.nfs)
>>> can cause more pain than just leaving things as is...
>> 
>> Is there any specific evidence that there will be pain if umount.nfs is removed? 
>> I can't think of any use case it would harm.  It's already broken in many cases,
>> and we have never heard of a specific application complaint about it.  If there 
>> had been a complaint we would have fixed it already.  UMNT is clearly vestigial.
> No I do not any evidence.... its just pure paranoia in the fact we will
> could easily break third party applications that will depend on the 
> existence of that binary... Plus removing the binary is simply not needed
> to fix a bug in the processing of /etc/mtab... Its just overkill... IMHO...

For a single bug, perhaps it is overkill.  However, there are a host of bugs around UMNT, not just this one.  A narrow fix for this bug will not address any of the other problems.  Removing umount.nfs and possibly performing UMNT in the kernel is a solution to all of these issues.

> I'll take a look and see if I can come up with a way to fixing the remount
> bug without remove the umount.nfs binary as well as continuing to
> send out the UMNT message... It has to be possible... 

The key problem is rewriting the mount options after the remount, based on what's already in /etc/mtab.  It's certainly possible, but it's going to add a lot of code. I think you will soon find that removing umount.nfs is significantly easier than trying to rewrite these options!

Also, you probably want a solution that fixes the legacy mount code as well as the text-based code.  I've looked at a solution that fits in the common code in mount.c to try addressing this.

Note that I never said it couldn't be done... just that a broader and simpler solution to all of this is to get rid of UMNT in user space.

-- 
chuck[dot]lever[at]oracle[dot]com




