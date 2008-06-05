From: "NeilBrown" <neilb@suse.de>
Subject: Re: [PATCH] nfs-utils:  "nfsstat -m" should report nfsv4 mounts
     too.
Date: Thu, 5 Jun 2008 22:08:06 +1000 (EST)
Message-ID: <35792.192.168.1.70.1212667686.squirrel@neil.brown.name>
References: <18503.29174.373900.73302@notabene.brown>
    <18503.29397.511629.809568@notabene.brown>
    <4CC1DC65-88C3-4F26-8FF2-016F6C1173CE@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "Steve Dickson" <steved@redhat.com>, linux-nfs@vger.kernel.org
To: "Scott Atchley" <atchley-vV262kQ/Wyo@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:54668 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756812AbYFEMIO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Jun 2008 08:08:14 -0400
In-Reply-To: <4CC1DC65-88C3-4F26-8FF2-016F6C1173CE-vV262kQ/Wyo@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, June 5, 2008 9:40 pm, Scott Atchley wrote:
> On Jun 5, 2008, at 1:00 AM, Neil Brown wrote:
>
>> That will, of course, report the "nfsd" mount as well, which we don't
>> want.  So let's try again.
>>
>> NeilBrown
>>
>>
>> diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
>> index aa6c961..d2cca8d 100644
>> --- a/utils/nfsstat/nfsstat.c
>> +++ b/utils/nfsstat/nfsstat.c
>> @@ -716,7 +716,7 @@ mounts(const char *name)
>> 		if (!(type = strtok(NULL, " \t")))
>> 			continue;
>>
>> -		if (strcmp(type, "nfs")) {
>> +		if (strcmp(type, "nfs") && strcmp(type,"nfs4")) {
>> 		    continue;
>> 		}
>
> Don't you want an OR?
>
> +		if (strcmp(type, "nfs") || strcmp(type,"nfs4")) {


Thanks for reviewing the patch (always appreciated), but no - I don't
want OR.
What I really want is to eradicate all usages of
    if (strcmp(X,Y))
in the world and make them
    if (strcmp(X,Y) != 0)

Then it is clearer that it is a "!=" test.
In this case, the condition as I had it means"

   If type is not nfs and type is not nfs4
(then continue)
which is what I want.

Your version says:
   If type is not nfs or type is not nfs4

and that will always be true.

+             if (strcmp(type, "nfs") != 0 && strcmp(type, "nfs4") != 0)) {


NeilBrown

