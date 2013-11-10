Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:51880 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752185Ab3KJWpX convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 10 Nov 2013 17:45:23 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Steve Dickson <SteveD@redhat.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Adding the nfs4_secure_mounts bool
Date: Sun, 10 Nov 2013 22:45:21 +0000
Message-ID: <CF19CE53-6F84-4FD2-9A97-69A068ED4A72@netapp.com>
References: <1384037221-7224-1-git-send-email-steved@redhat.com>
 <E061C7A8-DC27-49BA-93C2-DC2E9C19EA7B@netapp.com> <5280092E.60008@RedHat.com>
In-Reply-To: <5280092E.60008@RedHat.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 10, 2013, at 17:31, Steve Dickson <SteveD@redhat.com> wrote:

> Hey Trond,
> 
> On 09/11/13 18:12, Myklebust, Trond wrote:
>> 
>> On Nov 9, 2013, at 17:47, Steve Dickson <SteveD@redhat.com> wrote:
>> 
>>> The nfs4_secure_mounts controls whether security
>>> flavors will be tried during the establishing of
>>> NFSv4 state and the pseudoroot lookups.
>>> 
>>> This allows security daemon like rpc.gssd to
>>> tell the kernel that secure mounts should be tried.
>>> 
>>> To enable secure mounts:
>>>  echo "on" >  /proc/fs/nfsfs/secure
>>> 
>>> To disable secure mounts:
>>>  echo "off" >  /proc/fs/nfsfs/secure
>>> 
>>> Signed-off-by: Steve Dickson <steved@redhat.com>
>> 
>> Hi Steve,
>> 
>> So the rpc.gssd would flip the switch to “on” when it starts up and 
>> to “off” when it quits? 
> Yes that is the idea... rpc.gssd would be the gatekeeper if you will...
> I think its better than a mount option or module parameter since
> they, to used Jeff's words, "tend to live forever!" 
> 
>> What if someone does a ‘kill -9’?
> Things always break when they are killed with -9... It is what it is... :-)
> I am planning on used the atexit() API to manage this...  
> 
>> 
>> One alternative to the above scheme, which I believe that I’ve 
>> suggested before, is to have a permanent entry in rpc_pipefs 
>> that rpc.gssd can open and that the kernel can use to detect that 
>> it is running. If we make it /var/lib/nfs/rpc_pipefs/gssd/clnt00/gssd, 
>> then AFAICS we don’t need to change nfs-utils at all, since all newer 
>> versions of rpc.gssd will try to open for read anything of the form 
>> /var/lib/nfs/rpc_pipefs/*/clntXX/gssd...
> This seems like this would be reasonable... But from my understanding
> (which is limited in this area) this would not be an easy thing to do.

Actually, it should be very easy. We have all the machinery to create new pipes today, and they already track whether or not there is a gssd daemon listening.
The nice thing about this scheme is that if the gssd daemon dies, then the pipe is automatically closed, and the kernel tracking will immediately notice that.

> So I'm hoping we could used this patch as a bridge from here to there.
> To give the community a seamless way out of this 15 second delay, today!
> 
> This patch does not create a API changes like a module parameter or mount
> option would, plus it eliminates needless message being logged whether
> rpc.gssd is or is not running. Since it is seamless, pulling it out
> would will also be seamless…
> At the end of the day... rpc.gssd is going to have to change in the 
> short term. I think having rpc.gssd enabling secure mounts, like it
> has since Fedora 2, is still the right path. 

I disagree. I think that we can solve this particular problem without changing rpc.gssd or any of the sysinit/systemd start/end scripts.

--
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

