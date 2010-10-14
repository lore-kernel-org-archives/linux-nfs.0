Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48201 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754730Ab0JNS1r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Oct 2010 14:27:47 -0400
Message-ID: <4CB74B90.1050403@RedHat.com>
Date: Thu, 14 Oct 2010 14:27:28 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: whither NFS umount?
References: <678C897C-DECE-49C1-AFC4-B57CF3A09385@oracle.com>	<1286903046.24878.13.camel@heimdal.trondhjem.org>	<C5614601-A685-4D7A-8DC3-23375F88AF42@oracle.com>	<20101012151826.76b75f52@corrin.poochiereds.net>	<1286912649.1956.19.camel@heimdal.trondhjem.org>	<4CB5EF15.5030003@RedHat.com>	<20101013141317.66f23906@corrin.poochiereds.net>	<4CB5FE65.3090409@RedHat.com> <20101013145601.468acc2a@corrin.poochiereds.net> <4CB6090F.60301@RedHat.com> <E22DAFE2-A677-4D91-8976-5F641141DD36@oracle.com> <4CB63E81.9010100@RedHat.com> <1BC33C94-1C91-42BE-8FC1-5F85E0D6FABD@oracle.com>
In-Reply-To: <1BC33C94-1C91-42BE-8FC1-5F85E0D6FABD@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hey... 

On 10/14/2010 11:29 AM, Chuck Lever wrote:
> On Oct 13, 2010, at 7:19 PM, Steve Dickson wrote:
> 
> Using /proc/mounts to determine whether a mount point is NFSv4 or NFS is OK.
> However, /proc/mounts doesn't contain the original mount options used 
> to negotiate the mount.  Ideally, we want to use the original mount command 
> line options, and not the exact options that were negotiated, when doing the umount.
>
> The example I use to explain why /proc/mounts is not appropriate is a 
> simple mount "vers=3".  It negotiates with the server and discovers the 
> mount service is on port 4545.  The mount proceeds.  After a while the 
> server reboots, and puts the mount service on port 32769.  Our /proc/mounts 
> still has "mountport=4545" since that's what was negotiated at mount time 
> and passed to the kernel.  When umount tries the UMNT request, it will 
> read /proc/mounts, send the UMNT request to port 4545, and fail.
Either don't use the mountport that's in /proc/mounts or better yet
be prepared to do a GETPORT of the service when the UMNT call
fails with 'RPC: Program not registered'. Something that is 
commonly done.. 

> 
> Now, we could just say "screw it" and use the negotiated options rather 
> than the user-specified ones.  But that means there are still cases we 
> could perform the UMNT correctly which would not work.
Even the information in /etc/mtab can go stale. 
   mount mountport=4545 /mnt; server restart ; umount /mnt
were the server comes up on a different port. 

Granted this is a pilot error by the admin since if the 
port is  specified on the command line the server better
be listening on that port. The point being there can be stale 
information in any static list.

So regardless of which list is read (/etc/mtab or /proc/mounts)
we need to be prepared deal with static information...  

> 
> Another choice would be to store the original NFS-related command line
> mount options somewhere other than /etc/mtab, and leave them alone during 
> a remount.  If we can't perform UMNT in the kernel, I'd prefer this type
> of solution to either updating /etc/mtab on a remount or using /proc/mounts 
> during umount.
> 
> How about a file under /var/lib/nfs ?
I refer to my above statement... No matter where we put the list, there
is always a chance of the information in the list to go stale... 

So I would suggest we use /proc/mounts since that is the last known
valid options and then be prepared to deal with stale options.

> 
>>> If we no longer have to perform a UMNT, then there is no need to worry about
>>> the contents of /etc/mtab, for any reason, and it can go away.  I believe we 
>>> are the only file system that is holding up the complete removal of /etc/mtab.
>> I guess don't understand the justification of not send an industry
>> wide accepted and expected protocol message because we have bug in our 
>> code... Is a protocol message every single NFS client sends and
>> has sent for many many years... Now we are not going adhere to this
>> industry practice because we don't think its necessary since it 
>> will make things hard for us to fix bug? 
> 
> I'm sympathetic to that, though I also agree with Trond that UMNT is
> probably not relevant these days.  Since it is so unreliable, I think
> most implementations avoid depending on it for anything.
> 
Just today I found a bug talking about an older HPUX server not
being compatible with a Fedora client... So the assumption you guys
are making are very worrisome.... Its an assumption I simply can't make...   


>>> Is there any specific evidence that there will be pain if umount.nfs is removed? 
>>> I can't think of any use case it would harm.  It's already broken in many cases,
>>> and we have never heard of a specific application complaint about it.  If there 
>>> had been a complaint we would have fixed it already.  UMNT is clearly vestigial.
>> No I do not any evidence.... its just pure paranoia in the fact we will
>> could easily break third party applications that will depend on the 
>> existence of that binary... Plus removing the binary is simply not needed
>> to fix a bug in the processing of /etc/mtab... Its just overkill... IMHO...
> 
> For a single bug, perhaps it is overkill.  However, there are a host of bugs 
> around UMNT, not just this one.  A narrow fix for this bug will not address 
> any of the other problems.  Removing umount.nfs and possibly performing UMNT 
> in the kernel is a solution to all of these issues.
Go ahead and point me to those bug reports on those issues so I can 
get a better understanding... 

> 
>> I'll take a look and see if I can come up with a way to fixing the remount
>> bug without remove the umount.nfs binary as well as continuing to
>> send out the UMNT message... It has to be possible... 
> 
> The key problem is rewriting the mount options after the remount, based on what's 
> already in /etc/mtab.  It's certainly possible, but it's going to add a lot of 
> code. I think you will soon find that removing umount.nfs is significantly 
> easier than trying to rewrite these options!
> 
> Also, you probably want a solution that fixes the legacy mount code as well
> as the text-based code.  I've looked at a solution that fits in the common
> code in mount.c to try addressing this.
> 
> Note that I never said it couldn't be done... just that a broader and
> simpler solution to all of this is to get rid of UMNT in user space.
> 
At the end of the day I am dead against removing umount.nfs and stopping
sending the UMNT messages until it can be conclusively demonstrated 
we will continue be compatible all of the new and older servers out there.

Now if this cause more work then please send it my way, since I'm
the one being the stick in the mud, I'm the one that should do the
extra work... 

steved.
