Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:25866 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756065Ab2CSTUN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Mar 2012 15:20:13 -0400
Message-ID: <4F6786E5.7090802@RedHat.com>
Date: Mon, 19 Mar 2012 15:20:05 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] idmapd: logging of Local-Realms only lists the last
 realm
References: <1332160616-4522-1-git-send-email-steved@redhat.com> <51B1F466-FB87-4764-850E-3936DA71F637@oracle.com> <4F676E95.3090409@RedHat.com> <5295E5C7-2AD7-4D52-B3C1-8C24D964DCEF@oracle.com>
In-Reply-To: <5295E5C7-2AD7-4D52-B3C1-8C24D964DCEF@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Chuck,

On 03/19/2012 01:43 PM, Chuck Lever wrote:
> 
> On Mar 19, 2012, at 1:36 PM, Steve Dickson wrote:
> 
>>
>>
>> On 03/19/2012 10:05 AM, Chuck Lever wrote:
>>>
>>> On Mar 19, 2012, at 8:36 AM, Steve Dickson wrote:
>>>
>>>> From: Juno Krahn <Juno.Krahn@gmail.com>
>>>>
>>>> The list of local realms can be logged with a massage like the following:
>>>>  rpc.idmapd: libnfsidmap: Realms list: 'EXAMPLE2.COM'
>>>> Instead of printing a list of realms, only the last realm in the list is shown.
>>>>
>>>> https://bugzilla.redhat.com/show_bug.cgi?id=804152
>>>>
>>>> Signed-off-by: Steve Dickson <steved@redhat.com>
>>>
>>> The patch says "From: Juno Krahn" but the sign-off is from you. 
>> The patch came from:
>>    http://sourceforge.net/tracker/?func=detail&atid=903784&aid=3507122&group_id=183075 
>>
>> Now in the past I have asked people to post patches to this list with
>> the appropriate format, but with a no-brainier like this patch, I
>> thought that would have been a waste time on both ends.
>>
>>> Should you also have an SOB from Juno?
>> Juno gets credit for authoring the patch and I'm taking 
>> responsibility for the patch with my SOB... Does there
>> have to be any more process than that?? 
> 
> My understanding is that SOB is not about responsibility, but about the provenance of the work.
Hmm... I was thinking the Author tag would show more of the history 
of ownership than the SOB, but I'm not that much of a process guy... 

> It doesn't matter how large or small the patch is.  
True, but the complexity probably should. If ones pulling something out
of a bz to post upstream and its very simple patch and credit is given
to whom its due (both the Author and SOB tags exist on the posted patch)
I guess I just don't that as being a problem.

> The SOB is a public declaration of Juno's desire to pass the patch to you.
> Otherwise it looks like you didn't ask permission, even if you did.
I didn't, ask for Juno's SOB. Thats the point. I give Juno the
credit for writing the patch and I took responsibly for it. 
Basically trying to save Juno's time.
 
> 
> I've never seen another project maintainer drop an SOB like this, so I'm just asking (and copying the list for other opinions).  No objection, just want to make sure we are dotting our open-source "i"s and so on.
The SOB was never dropped because it never exist because I didn't ask 
for it. To your point, dropping an SOB would be bad and please point 
it out if I ever do so.

Again, I'm not a process guy... I like to get from A to B with the
least amount of pain. So if not asking for SOB from the author 
of a patch but I, the maintainer, is willing to add their SOB (i.e. 
willing to take responsibly) breaks an open-source rule, then I 
broke the rule. I must say though, I was under the impress that a 
SOB only had to exist, but again, process is not my forte ;-) 

steved.
 
