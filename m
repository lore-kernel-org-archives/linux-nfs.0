Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:50765 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751222Ab3KLF3s convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Nov 2013 00:29:48 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Neil Brown <neilb@suse.de>
CC: Charles Edward Lever <chuck.lever@oracle.com>,
        Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Adding the nfs4_secure_mounts bool
Date: Tue, 12 Nov 2013 05:29:46 +0000
Message-ID: <F58540AB-00BE-4AC5-B823-7260F30F8D58@netapp.com>
References: <1384037221-7224-1-git-send-email-steved@redhat.com>
 <E061C7A8-DC27-49BA-93C2-DC2E9C19EA7B@netapp.com>
 <52811CBB.3070204@RedHat.com>
 <E520DD5F-7E5A-4B6C-9FF6-6B74DA36FD1E@oracle.com>
 <5281290B.6000201@RedHat.com>
 <E0FBCF46-C70F-41E5-BA67-48406253CD7E@oracle.com>
 <20131112161135.25a487da@notabene.brown>
In-Reply-To: <20131112161135.25a487da@notabene.brown>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 12, 2013, at 0:11, NeilBrown <neilb@suse.de> wrote:

> On Mon, 11 Nov 2013 15:33:14 -0500 Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>> 
>> On Nov 11, 2013, at 1:59 PM, Steve Dickson <SteveD@redhat.com> wrote:
>> 
>>> On 11/11/13 13:30, Chuck Lever wrote:
>>>> 
>>>> On Nov 11, 2013, at 1:06 PM, Steve Dickson <SteveD@redhat.com> wrote:
>>>> 
>>>>> 
>>>>> 
>>>>> On 09/11/13 18:12, Myklebust, Trond wrote:
>>>>>> One alternative to the above scheme, which I believe that I’ve 
>>>>>> suggested before, is to have a permanent entry in rpc_pipefs 
>>>>>> that rpc.gssd can open and that the kernel can use to detect 
>>>>>> that it is running. If we make it /var/lib/nfs/rpc_pipefs/gssd/clnt00/gssd, 
>>>>>> then AFAICS we don’t need to change nfs-utils at all, since all newer 
>>>>>> versions of rpc.gssd will try to open for read anything of the form 
>>>>>> /var/lib/nfs/rpc_pipefs/*/clntXX/gssd...
>>>>> 
>>>>> After further review I am going going have to disagree with you on this.
>>>>> Since all the context is cached on the initial mount the kernel
>>>>> should be using the call_usermodehelper() to call up to rpc.gssd 
>>>>> to get the context, which means we could put this upcall noise 
>>>>> to bed... forever! :-)
>>>> 
>>>> Ask Al Viro for his comments on whether the kernel should start 
>>>> gssd (either a daemon or a script).  Hint: wear your kevlar underpants.
>>> I was thinking gssd would become a the gssd-cmd command... Al does not
>>> like the call_usermodehelper() interface?
>> 
>> He doesn't have a problem with call_usermodehelper() in general.  However, the kernel cannot guarantee security if it has to run a fixed command line.  Go ask him to explain.
>> 
>> 
>>> 
>>>> 
>>>> Have you tried Trond's approach yet?
>>> Looking into it... But nothing is trivial in that code... 
>>> 
>>>> 
>>>>> I realize this is not going happen overnight, so I would still
>>>>> like to propose my  nfs4_secure_mounts bool patch as bridge
>>>>> to the new call_usermodehelper()  since its the cleanest 
>>>>> solution so far... 
>>>>> 
>>>>> Thoughts?
>>>> 
>>>> We have workarounds already that work on every kernel since 3.8.
>>>> 
>>> The one that logs 5 to 20 lines (depending on thins are setup or not)
>>> per mount? That does work in some environments but no all. ;-)
>> 
>> When does running rpc.gssd not work?
> 
> Oohh ooh.. Pick me.  Pick me!! I can answer that one.
> 
> Running rpc.gssd does not work if you are mounting a filesystem using the IP
> address of the server and that IP address doesn't have a matching hostname
> anywhere that can be found:
> 
> In a newly creating minimal kvm install without rpc.gssd running,
>   mount 10.0.2.2:/home /mnt
> 
> sleeps for 15 seconds then succeeds.
> If I start rpc.gssd, then the same command takes forever.
> 
> strace of rpc.gssd shows that it complains about not being able to resolve
> the host name and "ERROR: failed to read service info".  Then it keeps the
> pipes open but never sends any message on them, so the kernel just keeps on
> waiting.
> 
> If I change "fail_keep_client" to "fail_destroy_client", then it closes the
> pipe and we get the 15 second timeout back.
> If I change  NI_NAMEREQD to 0, then the mount completes instantly.  (of course
> that make serious compromise security so it was just for testing).
> (Adding an entry to /etc/hosts also gives instant success).
> 
> I'm hoping that someone who understands this code will suggest something
> clever so I don't have to dig through all of it ;-)

rpc.gssd is supposed to do a downcall with a zero-length window and an error message in any situation where it cannot establish a GSS context. Normally, I’d expect an EACCES for the above scenario.

IOW: that’s a blatant rpc.gssd bug. One that will also affect you when you're doing NFSv3 and add ‘sec=krb5’ to the mount options.

Cheers
   Trond