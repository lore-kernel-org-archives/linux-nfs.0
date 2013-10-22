Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:31509 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751051Ab3JVIrZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Oct 2013 04:47:25 -0400
Message-ID: <52663BC0.9060304@RedHat.com>
Date: Tue, 22 Oct 2013 04:48:00 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Weston Andros Adamson <dros@netapp.com>
CC: Jeff Layton <jlayton@poochiereds.net>,
        linux-nfs list <linux-nfs@vger.kernel.org>,
        Simo Sorce <simo@redhat.com>
Subject: Re: Strange cred expiry behavior
References: <85F2BCBA-9565-497F-BFF4-FEB29301D655@netapp.com> <DCD436E3-9464-4BFB-8C1A-19912522824D@netapp.com> <20131021222339.2f1978d8@corrin.poochiereds.net> <1F9EA3CE-081B-4E9D-B83D-E6B33AE6FE1D@netapp.com> <4BDA1624-63A7-4325-BB4B-4988C1D37127@netapp.com>
In-Reply-To: <4BDA1624-63A7-4325-BB4B-4988C1D37127@netapp.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 21/10/13 22:38, Weston Andros Adamson wrote:
> 
> On Oct 21, 2013, at 10:31 PM, Weston Andros Adamson <dros@netapp.com>
>  wrote:
> 
>>
>> On Oct 21, 2013, at 10:23 PM, Jeff Layton <jlayton@poochiereds.net> wrote:
>>
>>> On Mon, 21 Oct 2013 23:53:16 +0000
>>> Weston Andros Adamson <dros@netapp.com> wrote:
>>>
>>>> I traced this behavior back to:
>>>>
>>>> commit 302de786930a2c533068f9d8909a817b40f07c32
>>>> Author: Simo Sorce <simo@redhat.com>
>>>> Date:   Fri Apr 19 13:02:36 2013 -0400
>>>>
>>>>   gssd: Allow GSSAPI to try to acquire credentials first.
>>>>
>>>>
>>>> And in particular:
>>>>
>>>> -               for (dirname = ccachesearch; *dirname != NULL; dirname++) {
>>>> +               /* Try first to acquire credentials directly via GSSAPI */
>>>> +               err = gssd_acquire_user_cred(uid, &gss_cred);
>>>> +               if (!err)
>>>> +                       create_resp = create_auth_rpc_client(clp, &rpc_clnt, &auth, uid,
>>>> +                                                            AUTHTYPE_KRB5, gss_cred);
>>>> +               /* if create_auth_rplc_client fails try the traditional method of
>>>> +                * trolling for credentials */
>>>> +               for (dirname = ccachesearch; create_resp != 0 && *dirname != NULL; dirname++) {
>>>>
>>>
>>>
>>>> A couple of things:
>>>>
>>>> - If I get rid of the "Try first to acquire credentials directly via GSSAPI" part, expiry works as before.
>>>>
>>>
>>>
>>> Steve just merged a couple of patches from me that change this code
>>> some. It's probably worth testing with those before you make any
>>> changes.
>>>
>>
>> Thanks, I'll check it out.
> 
> Bisecting brought me to 302de786930a2c533068f9d8909a817b40f07c32 and I've confirmed that the problem is still in steved's master branch as of today. Are you sure the patches you're thinking of have been merged?
I believe the ones in question are 

commit 6b53fc9ce38ba6fff2fd5c2f6ed143747067a39d
Author: Jeff Layton <jlayton@redhat.com>
Date:   Mon Oct 21 13:28:06 2013 -0400

    gssd: do a more thorough change of identity after forking


commit f9cac65972da588d5218236de60a7be11247a8aa
Author: Jeff Layton <jlayton@redhat.com>
Date:   Mon Oct 21 13:27:22 2013 -0400

    gssd: have process_krb5_upcall fork before handling upcall

Which have been committed... 

steved.
