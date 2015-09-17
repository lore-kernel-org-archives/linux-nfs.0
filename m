Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:49678 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751868AbbIQSBT convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Sep 2015 14:01:19 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH] Use a separate superblock if mount requires a different security flavor
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAHQdGtSB6XwQme2GBsQzfjxZf4qJRPhsWSMf+mWbE5501HVBzw@mail.gmail.com>
Date: Thu, 17 Sep 2015 14:01:08 -0400
Cc: Frank Filz <ffilzlnx@mindspring.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <3E2CC450-BB4D-4F08-957D-EB78FE3665BE@oracle.com>
References: <1442429367.24127.6.camel@localhost.localdomain> <CAHQdGtSWaeAyjeKFV5AxJPou_94esPnso5sQrA=wfep6m5qP5Q@mail.gmail.com> <08D9E2B0-B4A8-4DF0-9BB7-B19B2D260E97@oracle.com> <CAHQdGtTJdVf1UU7H=R-VdZPxT=BAKA04bB-WGbPqR38JkUpwMA@mail.gmail.com> <001a01d0f0c7$ca84e6d0$5f8eb470$@mindspring.com> <CAHQdGtSB6XwQme2GBsQzfjxZf4qJRPhsWSMf+mWbE5501HVBzw@mail.gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Sep 16, 2015, at 11:32 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> On Wed, Sep 16, 2015 at 5:36 PM, Frank Filz <ffilzlnx@mindspring.com> wrote:
>>> On Wed, Sep 16, 2015 at 4:55 PM, Chuck Lever <chuck.lever@oracle.com>
>>> wrote:
>>>> 
>>>> On Sep 16, 2015, at 4:52 PM, Trond Myklebust
>>> <trond.myklebust@primarydata.com> wrote:
>>>> 
>>>>> On Wed, Sep 16, 2015 at 2:49 PM, Frank Filz <ffilzlnx@mindspring.com>
>>> wrote:
>>>>>> If a server has two exports from the same filesystem but with
>>>>>> different security flavors allowed, when the client mounts first one
>>>>>> and then the second, the same super block was being used. This
>>>>>> resulted in the security flavor for the first export being applied
>>>>>> to access to the second export.
>>>>>> 
>>>>>> The fix is simply to check the security flavor of the nfs_server
>>>>>> temporarily constructed for the second mount within
>>> nfs_compare_super.
>>>>>> 
>>>>>> Signed-off-by: Frank S. Filz <ffilzlnx@mindspring.com>
>>>>>> ---
>>>>>> fs/nfs/super.c | 3 +++
>>>>>> 1 file changed, 3 insertions(+)
>>>>>> 
>>>>>> diff --git a/fs/nfs/super.c b/fs/nfs/super.c index 084af10..44d60f1
>>>>>> 100644
>>>>>> --- a/fs/nfs/super.c
>>>>>> +++ b/fs/nfs/super.c
>>>>>> @@ -2455,6 +2455,9 @@ static int nfs_compare_super(struct
>>>>>> super_block *sb, void *data)
>>>>>>       struct nfs_server *server = sb_mntdata->server, *old =
>>>>>> NFS_SB(sb);
>>>>>>       int mntflags = sb_mntdata->mntflags;
>>>>>> 
>>>>>> +       if(old->client->cl_auth->au_flavor
>>>>>> +          != server->client->cl_auth->au_flavor)
>>>>>> +               return 0;
>>>>> 
>>>>> Isn't this check already being performed in
>>>>> nfs_compare_mount_options()? As far as I can see, the difference is
>>>>> that you are checking unconditionally, whereas
>>>>> nfs_compare_mount_options only does so if there was a 'sec=' line
>>>>> specified in the mount options.
>>>> 
>>>> Right. If the user doesn't provide a sec=, the security flavor is
>>>> autonegotiated. In the case Frank describes, there are two directories
>>>> shared on the server, each from the same FSID but using distinct
>>>> security policies.
>>>> 
>>>> So the mount options comparison is inadequate if no sec= is specified
>>>> on the mount command line.
>>> 
>>> We don't claim to support autonegotiation of multiple security policies per
>>> filesystem, in general. We only claim to support one auth flavour per super
>>> block.
>>> 
>>> If I understand you correctly, you are knowingly trying to work around that
>>> limitation by performing multiple mounts of the same filesystem and force it
>>> to use multiple super blocks. Why can't you then also specify the 'sec='?
>> 
>> I see that point, but why not just make this case work smoothly rather than force the user to go back and specify -o sec on the mount?
> 
> The main issue is that it violates the policy that we must try our
> best not to set up situations where the client has cache consistency
> issues due to the existence of multiple superblocks that all have page
> caches for the same file.

The parts of the physical FS's namespace that are accessible
by each security flavor are disjoint. Aside from hardlinks, is
there any possibility for cache aliasing in this scenario?


>> Actually all that is necessary is SOME difference in mount options (or use -o nosharedcache, which could be used on all the mounts so all can have the same mount options...) and allow security negotiation to work.
> 
> I'd expect there to be no problems if the admin specifies -o
> nosharedcache. Please do let me know if that fails to work.
> 
>> An interesting question is if there are any servers out there that don't typically provide different FSID for different portions of the namespace, but also provide a mechanism to specify different security policies for different portions of the namespace?
> 
> That sort of situation is difficult to manage.

But appears to be allowed by Solaris, and likely also by Linux
and Ganesha. I think we are going to have to consider it,
particularly if there is no prohibition against it in the RFCs.

Meanwhile, I need to document this behavior (internally) and
thus need to understand if this is a server bug, a client bug,
or a protocol bug. Thoughts about which?


> How do you deal with
> hard links that cross the security policy boundary? I haven't seen any
> discussion of how that sort of case is expected to work, and of what
> requirements it imposes on clients and servers.
> 
> Cheers
>  Trond

--
Chuck Lever



