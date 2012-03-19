Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:39941 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030705Ab2CSRn6 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Mar 2012 13:43:58 -0400
Subject: Re: [PATCH 1/1] idmapd: logging of Local-Realms only lists the last realm
Mime-Version: 1.0 (Apple Message framework v1257)
Content-Type: text/plain; charset=US-ASCII
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4F676E95.3090409@RedHat.com>
Date: Mon, 19 Mar 2012 13:43:52 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <5295E5C7-2AD7-4D52-B3C1-8C24D964DCEF@oracle.com>
References: <1332160616-4522-1-git-send-email-steved@redhat.com> <51B1F466-FB87-4764-850E-3936DA71F637@oracle.com> <4F676E95.3090409@RedHat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 19, 2012, at 1:36 PM, Steve Dickson wrote:

> 
> 
> On 03/19/2012 10:05 AM, Chuck Lever wrote:
>> 
>> On Mar 19, 2012, at 8:36 AM, Steve Dickson wrote:
>> 
>>> From: Juno Krahn <Juno.Krahn@gmail.com>
>>> 
>>> The list of local realms can be logged with a massage like the following:
>>>  rpc.idmapd: libnfsidmap: Realms list: 'EXAMPLE2.COM'
>>> Instead of printing a list of realms, only the last realm in the list is shown.
>>> 
>>> https://bugzilla.redhat.com/show_bug.cgi?id=804152
>>> 
>>> Signed-off-by: Steve Dickson <steved@redhat.com>
>> 
>> The patch says "From: Juno Krahn" but the sign-off is from you. 
> The patch came from:
>    http://sourceforge.net/tracker/?func=detail&atid=903784&aid=3507122&group_id=183075 
> 
> Now in the past I have asked people to post patches to this list with
> the appropriate format, but with a no-brainier like this patch, I
> thought that would have been a waste time on both ends.
> 
>> Should you also have an SOB from Juno?
> Juno gets credit for authoring the patch and I'm taking 
> responsibility for the patch with my SOB... Does there
> have to be any more process than that?? 

My understanding is that SOB is not about responsibility, but about the provenance of the work.  It doesn't matter how large or small the patch is.  The SOB is a public declaration of Juno's desire to pass the patch to you.  Otherwise it looks like you didn't ask permission, even if you did.

I've never seen another project maintainer drop an SOB like this, so I'm just asking (and copying the list for other opinions).  No objection, just want to make sure we are dotting our open-source "i"s and so on.

> steved. 
> 
>> 
>>> ---
>>> libnfsidmap.c |    3 ++-
>>> 1 files changed, 2 insertions(+), 1 deletions(-)
>>> 
>>> diff --git a/libnfsidmap.c b/libnfsidmap.c
>>> index 57bb6c3..641d766 100644
>>> --- a/libnfsidmap.c
>>> +++ b/libnfsidmap.c
>>> @@ -285,8 +285,9 @@ int nfs4_init_name_mapping(char *conffile)
>>> 			}
>>> 			buf = malloc(siz);
>>> 			if (buf) {
>>> +				*buf = 0;
>>> 				TAILQ_FOREACH(r, &local_realms->fields, link) {
>>> -					sprintf(buf, "'%s' ", r->field);
>>> +					sprintf(buf+strlen(buf), "'%s' ", r->field);
>>> 				}
>>> 				IDMAP_LOG(1, ("libnfsidmap: Realms list: %s", buf));
>>> 				free(buf);
>>> -- 
>>> 1.7.7.5
>>> 
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




