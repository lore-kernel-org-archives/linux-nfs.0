From: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Subject: Re: [PATCH 4/5] knfsd: convert knfsd to kthread API
Date: Tue, 10 Jun 2008 20:50:57 +1000
Message-ID: <484E5C91.6000502@melbourne.sgi.com>
References: <1212765171-26042-1-git-send-email-jlayton@redhat.com>	<1212765171-26042-2-git-send-email-jlayton@redhat.com>	<1212765171-26042-3-git-send-email-jlayton@redhat.com>	<1212765171-26042-4-git-send-email-jlayton@redhat.com>	<1212765171-26042-5-git-send-email-jlayton@redhat.com>	<20080606172431.GA761@fieldses.org>	<20080606141116.07b79b14@tleilax.poochiereds.net>	<20080606154948.303aba28@tleilax.poochiereds.net>	<20080609130830.GA21769@fieldses.org>	<20080609091948.0b2b19a9@tleilax.poochiereds.net>	<20080609183923.GE28584@fieldses.org> <20080609145459.1adda51a@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org, neilb@suse.de
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay2.sgi.com ([192.48.171.30]:57148 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751264AbYFJKzA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Jun 2008 06:55:00 -0400
In-Reply-To: <20080609145459.1adda51a-RtJpwOs3+0O+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff Layton wrote:
> On Mon, 9 Jun 2008 14:39:23 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
>
>   
>> On Mon, Jun 09, 2008 at 09:19:48AM -0400, Jeff Layton wrote:
>>     
>>> On Mon, 9 Jun 2008 09:08:30 -0400
>>> "J. Bruce Fields" <bfields@fieldses.org> wrote:
>>>
>>>       
>>>> On Fri, Jun 06, 2008 at 03:49:48PM -0400, Jeff Layton wrote:
>>>>         
>>>>> On Fri, 6 Jun 2008 14:11:16 -0400
>>>>> Jeff Layton <jlayton@redhat.com> wrote:
>>>>>
>>>>>           
>>>>>> On Fri, 6 Jun 2008 13:24:31 -0400
>>>>>> "J. Bruce Fields" <bfields@fieldses.org> wrote:
>>>>>>
>>>>>>             
>>>>> ...
>>>>>           
>>>>>>> How does the module refcounting work after this patch?
>>>>>>>
>>>>>>> --b.
>>>>>>>
>>>>>>>               
>>>>>> I think I've goofed this part, actually. I was thinking that we didn't
>>>>>> need to bump the refcount here, and that the kernel would realize that
>>>>>> nfsd() hadn't returned and would prevent unloading until it had. This
>>>>>> doesn't seem to be the case. I'll need to go back and add refcounting
>>>>>> back in.
>>>>>>
>>>>>>             
>>>>> Here's a respun patch that adds back in the module refcounts and also
>>>>> removes the unneeded "err = 0;" at the bottom of the loop. Thoughts?
>>>>>           
>>>> Looks good to me.  I'll apply all 5 (with this version of #4) if noone
>>>> catches something else.
>>>>
>>>> --b.
>>>>
>>>>         
>>> Sounds good. My only concern here is whether moving the __module_get
>>> from the RPC layer to nfsd() itself is OK.
>>>       
>> Oh, I see, I missed that.
>>
>>     
>>> I *think* it is since the
>>> nfsctl and /proc/fs/nfsd routines are all part of the nfsd module, so
>>> we're guaranteed to have a reference there anyway, but if there are
>>> potential races then we may want to go back to the old way.
>>>       
>> The vfs should take care that e.g. it gets a reference on the module
>> before creating an open file for the nfsd filesystem. 
Yes, but indirectly; I believe the module refcount belongs to the nfsd
filesystem super_block, and having an open file on that filesystem keeps
a vfsmount refcount which keeps the super_block refcount which keeps the
module refcount.
>>  But it don't see
>> how anything can guarantee that the __module_get() in the new nfsd
>> thread completes before whoever called svc_set_num_threads() returns and
>> drops their reference.
>>
>> So, yeah, I think it's not right.
>>
>>     
Agreed.
>
> Ok, that makes sense. I'll need to respin the set then since we'll need
> the sv_module field in the svc_serv struct after all. Let me do that
> and get back to you...
>
>   

Bother, I think that's right.

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
The cake is *not* a lie.
I don't speak for SGI.

