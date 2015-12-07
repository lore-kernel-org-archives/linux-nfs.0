Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:45010 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932296AbbLGRTa convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Dec 2015 12:19:30 -0500
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Subject: Re: [nfs-utils PATCH] statd: make statd_canonical_name emit a warning if the presentation address maps to an empty hostname
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20151207170414.GI4405@tonberry.usersys.redhat.com>
Date: Mon, 7 Dec 2015 12:19:26 -0500
Cc: Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <630B6619-1142-4717-A860-0FC0703FCE0B@oracle.com>
References: <1449506523-21897-1-git-send-email-smayhew@redhat.com> <9457C117-431E-40ED-9A3A-5EBE866C7BAF@oracle.com> <20151207170414.GI4405@tonberry.usersys.redhat.com>
To: Scott Mayhew <smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Dec 7, 2015, at 12:04 PM, Scott Mayhew <smayhew@redhat.com> wrote:
> 
> On Mon, 07 Dec 2015, Chuck Lever wrote:
> 
>> 
>>> On Dec 7, 2015, at 11:42 AM, Scott Mayhew <smayhew@redhat.com> wrote:
>>> 
>>> Certain name resolution misconfigurations (for example, a hosts file
>>> entry with an ip address but no hostnames) can cause get_nameinfo() to
>>> return an empty string in buf, which will lead to this cryptic failure:
>>> 
>>> Dec  7 09:37:44 hostname rpc.statd[8024]: Failed to insert: creating
>>> /var/lib/nfs/statd/sm/: Is a directory
>>> Dec  7 09:37:44 hostname rpc.statd[8024]: STAT_FAIL to
>>> hostname.example.com for SM_MON of 192.168.1.2
>>> Dec  7 09:37:44 hostname kernel: lockd: cannot monitor 192.168.1.2
>>> 
>>> It's better in that case to just go ahead and use the presentation
>>> address and log a more helpful warning:
>> 
>> Doesn???t this change wire behavior? Some peers do not appreciate
>> receiving a presentation address, which is why statd/sm_notify
>> avoid sending them.
> 
> I was just trying to keep it in line with the behavior you had added in
> e22f5a9c (statd: statd fails to monitor if no reverse mapping of mon_name
> exists).  As it stands now, if get_nameinfo() fails outright then the
> presentation address is used and we're able to monitor the peer just
> fine... but get_nameinfo() succeeds and returns an empty hostname then
> we ultimately wind up failing to monitor the peer.

OK, I see the “bug-for-bug compatible” red flag in the
description of e22f5a9c. I guess this shouldn’t even
fire a warning then, it should just return the address.

We should correct the documenting comment for
statd_canonical_name(). Just delete the sentence that
begins “We won’t monitor peers”.

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>


>> I think it would be better to _skip_ this address and print the
>> warning? IMO.
>> 
> That's actually what I had at first and if you think that's better then
> that's fine too.  The rest of the errors would still get logged then,
> but at least the reason would be a little more apparent.
> 
> -Scott
>> 
>>> Dec  7 10:24:52 hostname rpc.statd[14224]: get_nameinfo returned empty
>>> hostname for 10.10.183.219.  Fix your name resolution!
>>> 
>>> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
>>> ---
>>> utils/statd/hostname.c | 6 ++++++
>>> 1 file changed, 6 insertions(+)
>>> 
>>> diff --git a/utils/statd/hostname.c b/utils/statd/hostname.c
>>> index c61087c..86d11ca 100644
>>> --- a/utils/statd/hostname.c
>>> +++ b/utils/statd/hostname.c
>>> @@ -211,6 +211,12 @@ statd_canonical_name(const char *hostname)
>>> 			/* OK to use presentation address,
>>> 			 * if no reverse map exists */
>>> 			return strdup(hostname);
>>> +		else if (buf[0] == '\0') {
>>> +			xlog_warn("get_nameinfo returned empty hostname for "
>>> +					"%s. Fix your name resolution!",
>>> +					hostname);
>>> +			return strdup(hostname);
>>> +		}
>>> 		return strdup(buf);
>>> 	}
>>> 
>>> -- 
>>> 2.4.3
>>> 
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 
>> --
>> Chuck Lever
>> 
>> 
>> 
>> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever




