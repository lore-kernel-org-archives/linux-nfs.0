Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:34858 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752928Ab3JVCiZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Oct 2013 22:38:25 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Jeff Layton <jlayton@poochiereds.net>
CC: linux-nfs list <linux-nfs@vger.kernel.org>, Simo Sorce <simo@redhat.com>
Subject: Re: Strange cred expiry behavior
Date: Tue, 22 Oct 2013 02:38:23 +0000
Message-ID: <4BDA1624-63A7-4325-BB4B-4988C1D37127@netapp.com>
References: <85F2BCBA-9565-497F-BFF4-FEB29301D655@netapp.com>
 <DCD436E3-9464-4BFB-8C1A-19912522824D@netapp.com>
 <20131021222339.2f1978d8@corrin.poochiereds.net>
 <1F9EA3CE-081B-4E9D-B83D-E6B33AE6FE1D@netapp.com>
In-Reply-To: <1F9EA3CE-081B-4E9D-B83D-E6B33AE6FE1D@netapp.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 21, 2013, at 10:31 PM, Weston Andros Adamson <dros@netapp.com>
 wrote:

> 
> On Oct 21, 2013, at 10:23 PM, Jeff Layton <jlayton@poochiereds.net> wrote:
> 
>> On Mon, 21 Oct 2013 23:53:16 +0000
>> Weston Andros Adamson <dros@netapp.com> wrote:
>> 
>>> I traced this behavior back to:
>>> 
>>> commit 302de786930a2c533068f9d8909a817b40f07c32
>>> Author: Simo Sorce <simo@redhat.com>
>>> Date:   Fri Apr 19 13:02:36 2013 -0400
>>> 
>>>   gssd: Allow GSSAPI to try to acquire credentials first.
>>> 
>>> 
>>> And in particular:
>>> 
>>> -               for (dirname = ccachesearch; *dirname != NULL; dirname++) {
>>> +               /* Try first to acquire credentials directly via GSSAPI */
>>> +               err = gssd_acquire_user_cred(uid, &gss_cred);
>>> +               if (!err)
>>> +                       create_resp = create_auth_rpc_client(clp, &rpc_clnt, &auth, uid,
>>> +                                                            AUTHTYPE_KRB5, gss_cred);
>>> +               /* if create_auth_rplc_client fails try the traditional method of
>>> +                * trolling for credentials */
>>> +               for (dirname = ccachesearch; create_resp != 0 && *dirname != NULL; dirname++) {
>>> 
>> 
>> 
>>> A couple of things:
>>> 
>>> - If I get rid of the "Try first to acquire credentials directly via GSSAPI" part, expiry works as before.
>>> 
>> 
>> 
>> Steve just merged a couple of patches from me that change this code
>> some. It's probably worth testing with those before you make any
>> changes.
>> 
> 
> Thanks, I'll check it out.

Bisecting brought me to 302de786930a2c533068f9d8909a817b40f07c32 and I've confirmed that the problem is still in steved's master branch as of today. Are you sure the patches you're thinking of have been merged?

-dros

> 
>>> - It says "if create_auth_rplc_client fails try the traditional method of trolling for credentials" but I see nothing that checks to see if create_resp != 0 before falling back to the old method.  I added this check and everything seems right (it doesn't fix the expiry issue).
>>> 
>> 
>> Isn't that what the "create_resp != 0" check in the for loop does?
> 
> Heh yeah, thanks!
> 
> -dros
> 
>> 
>>> 
>>> I should have some time tomorrow to look further at the expiry issue…
>>> 
>>> -dros
>>> 
>>> 
>> 
>>> On Oct 21, 2013, at 4:07 PM, Weston Andros Adamson <dros@netapp.com> wrote:
>>> 
>>>> I saw this issue when revived my branch for using SP4_MACH_CRED only in the error (EKEYEXPIRED) path, and was able to reproduce it on Trond's testing branch, so this behavior is definitely new.  The client is running F19 updated pretty recently (nfs-utils 1.2.8-4.0.fc19).
>>>> 
>>>> The issue:
>>>> 
>>>> - mount a kerberos export
>>>> 
>>>> - kinit with a really short lifetime: "kinit -l 1m"
>>>> 
>>>> - run something (like dd) that will hold a file open and write to it for more than the lifetime of the kinit
>>>> 
>>>> ! - after the credential expire, the number of keys listed in "klist" starts to grow. Notice how the "Valid starting" time is after the "Expires" time.  The list seems to grow forever - my test program writes 4k every second and the list seemed to grow by 1 line per second.  Example klist output:
>>>> 
>>>> 
>>>> Ticket cache: DIR::/run/user/1749600001/krb5cc/tktYmpGlX
>>>> Default principal: dros@APIKIA.FAKE
>>>> 
>>>> Valid starting       Expires              Service principal
>>>> 10/21/2013 15:39:38  10/21/2013 15:40:35  krbtgt/APIKIA.FAKE@APIKIA.FAKE
>>>> 10/21/2013 15:39:40  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE
>>>> 10/21/2013 15:40:35  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE
>>>> 10/21/2013 15:40:36  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE
>>>> 10/21/2013 15:40:37  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE
>>>> 10/21/2013 15:40:37  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE
>>>> 10/21/2013 15:40:38  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE
>>>> 10/21/2013 15:40:38  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE
>>>> 10/21/2013 15:40:39  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE
>>>> 10/21/2013 15:40:39  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE
>>>> 10/21/2013 15:40:39  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE
>>>> 10/21/2013 15:40:39  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE
>>>> 10/21/2013 15:40:40  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE
>>>> 10/21/2013 15:40:40  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE
>>>> 10/21/2013 15:40:41  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE
>>>> 10/21/2013 15:40:41  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE
>>>> 10/21/2013 15:40:42  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE
>>>> 10/21/2013 15:40:42  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE
>>>> 10/21/2013 15:40:42  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE
>>>> 
>>>> This seems like a gssd bug in handling cred refresh upcalls. I'll debug further and hopefully find a fix.
>>>> 
>>>> Has anyone seen this issue before or have any thoughts on recent changes that could cause this? I definitely didn't see this a little more than a month ago when I started testing cred expiry...
>>>> 
>>>> -dros--
>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>> 
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 
>> 
>> -- 
>> Jeff Layton <jlayton@poochiereds.net>
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

