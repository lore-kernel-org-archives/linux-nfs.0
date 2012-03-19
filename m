Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:54993 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932528Ab2CSRg2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Mar 2012 13:36:28 -0400
Message-ID: <4F676E95.3090409@RedHat.com>
Date: Mon, 19 Mar 2012 13:36:21 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] idmapd: logging of Local-Realms only lists the last
 realm
References: <1332160616-4522-1-git-send-email-steved@redhat.com> <51B1F466-FB87-4764-850E-3936DA71F637@oracle.com>
In-Reply-To: <51B1F466-FB87-4764-850E-3936DA71F637@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/19/2012 10:05 AM, Chuck Lever wrote:
> 
> On Mar 19, 2012, at 8:36 AM, Steve Dickson wrote:
> 
>> From: Juno Krahn <Juno.Krahn@gmail.com>
>>
>> The list of local realms can be logged with a massage like the following:
>>   rpc.idmapd: libnfsidmap: Realms list: 'EXAMPLE2.COM'
>> Instead of printing a list of realms, only the last realm in the list is shown.
>>
>> https://bugzilla.redhat.com/show_bug.cgi?id=804152
>>
>> Signed-off-by: Steve Dickson <steved@redhat.com>
> 
> The patch says "From: Juno Krahn" but the sign-off is from you. 
The patch came from:
    http://sourceforge.net/tracker/?func=detail&atid=903784&aid=3507122&group_id=183075 

Now in the past I have asked people to post patches to this list with
the appropriate format, but with a no-brainier like this patch, I
thought that would have been a waste time on both ends.    

>  Should you also have an SOB from Juno?
Juno gets credit for authoring the patch and I'm taking 
responsibility for the patch with my SOB... Does there
have to be any more process than that?? 

steved. 
 
> 
>> ---
>> libnfsidmap.c |    3 ++-
>> 1 files changed, 2 insertions(+), 1 deletions(-)
>>
>> diff --git a/libnfsidmap.c b/libnfsidmap.c
>> index 57bb6c3..641d766 100644
>> --- a/libnfsidmap.c
>> +++ b/libnfsidmap.c
>> @@ -285,8 +285,9 @@ int nfs4_init_name_mapping(char *conffile)
>> 			}
>> 			buf = malloc(siz);
>> 			if (buf) {
>> +				*buf = 0;
>> 				TAILQ_FOREACH(r, &local_realms->fields, link) {
>> -					sprintf(buf, "'%s' ", r->field);
>> +					sprintf(buf+strlen(buf), "'%s' ", r->field);
>> 				}
>> 				IDMAP_LOG(1, ("libnfsidmap: Realms list: %s", buf));
>> 				free(buf);
>> -- 
>> 1.7.7.5
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
