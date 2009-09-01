From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] NFS: Change default behavior when "sec=" is not
	specified by user
Date: Tue, 1 Sep 2009 12:09:14 -0400
Message-ID: <20090901160914.GG22846@fieldses.org>
References: <20090901143012.3978.11441.stgit@matisse.1015granger.net> <20090901150545.GA22846@fieldses.org> <7C5C14D9-F315-4DF8-A2F4-C7F0981AC968@oracle.com> <20090901151830.GC22846@fieldses.org> <18678BB3-52C6-4376-BBD1-50B8947BAAC7@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@fys.uio.no, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:34604 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751508AbZIAQJP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Sep 2009 12:09:15 -0400
In-Reply-To: <18678BB3-52C6-4376-BBD1-50B8947BAAC7@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 01, 2009 at 11:52:39AM -0400, Chuck Lever wrote:
>
> On Sep 1, 2009, at 11:18 AM, J. Bruce Fields wrote:
>
>> On Tue, Sep 01, 2009 at 11:10:36AM -0400, Chuck Lever wrote:
>>> On Sep 1, 2009, at 11:05 AM, J. Bruce Fields wrote:
>>>> On Tue, Sep 01, 2009 at 10:31:38AM -0400, Chuck Lever wrote:
>>>>> Currently the kernel's MNT client always uses AUTH_UNIX if no  
>>>>> "sec="
>>>>> mount option was specified.  In the interest of conforming more
>>>>> closely to RFC 2623, teach the MNT client to use the first flavor 
>>>>> on
>>>>> the server's returned authflavor list instead of AUTH_UNIX, if  
>>>>> "sec="
>>>>> was not specified.
>>>>>
>>>>> When the user does not specify "sec=" :
>>>>>
>>>>> o  For NFSv2 and NFSv4: the default is always AUTH_UNIX  
>>>>> (unchanged).
>>>>>
>>>>> o  For NFSv3: if the server does not return an auth flavor list,  
>>>>> use
>>>>>   AUTH_UNIX by default; if the server does return a list, use the
>>>>>   first entry on the list by default.
>>>>
>>>> Sounds good, but also:
>>>>
>>>> 	1. Even when sec= is provided, we should probably still check
>>>> 	the passed-in security against the server-returned list.
>>>> 	(Otherwise AUTH_NULL mounts will almost *always* succeed, even
>>>> 	when no subsequent file operation would, thanks to the
>>>> 	allow-AUTH_NULL-on-mount behavior recommended by rfc 2523).
>>>> 	http://marc.info/?l=linux-nfs&m=125088837303339&w=2
>>>>
>>>> 	2. In the absence of sec=, we should probably *not* choose
>>>> 	AUTH_NULL.  (All mountd's before 1.1.3 list AUTH_NULL first on
>>>> 	the returned list, so users with older servers may wonder why a
>>>> 	client upgrade is making files they create suddenly be owned by
>>>> 	nobody.) http://marc.info/?l=linux-nfs&m=125089022306281&w=2
>>>>
>>>> 	3. As a special exception, we should probably allow an explicit
>>>> 	"sec=null" to override #1 above, since ommission of AUTH_NULL
>>>> 	from post-1.1.3 mountd returns will make it otherwise impossible
>>>> 	to mount with AUTH_NULL.
>>>> 	http://marc.info/?l=linux-nfs&m=125113569524411&w=2
>>>>
>>>> Oops, my bad: I see now from the code that you did actually do #1,  
>>>> you
>>>> just didn't mention it above.  OK!
>>>>
>>>> I don't see #2 or #3, though maybe they're already handled
>>>> somewhere....
>>>
>>> No, not in the kernel's MNT client.  #3 seems like a server bug to  
>>> me,
>>> though.
>>
>> Alas, it's apparently a workaround for a client bug: see the url
>> referenced after #3.  (But I don't know what client versions that bug
>> was in.  If someone investigated and found they weren't widely
>> distributed, I'd take a patch to remove the workaround.)
>
> How are clients supposed to tell if the server actually supports  
> AUTH_NULL but didn't list it, versus the admin specifically forbidding  
> the use of AUTH_NULL?

They can't.  So the compromise I proposed was to avoid negotiating
AUTH_NULL automatically, but to allow the user's explicit sec=null to
override the server's returned list.  That said, I think I'm convinced:

> Mountd should list AUTH_NULL if the server admin specified it (although 
> it doesn't need to list AUTH_NULL by default).  The server is allowed to 
> reorder the flavor list, not the client, according to RFC 2623.  The 
> server's admin may even _prefer_ "rw,sec=null" access, in which case 
> listing AUTH_NULL first is actually desired.

And in fact that's the way a recent linux server works.

So if you do #2 above but not #3, then you can tell people: if you
really need auth_null, you need to a) request it explicitly on the mount
commandline, b) upgrade to a recent mountd (at least 1.1.4), and c) list
it explicitly on the server export.

And, sure, that'd be OK with me, and would probably be better than
adding another exception, so I'm OK with skipping #3.  (We definitely
shouldn't omit #2, though.)

--b.
