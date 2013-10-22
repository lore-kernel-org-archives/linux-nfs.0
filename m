Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:32087 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753077Ab3JVMwy convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Oct 2013 08:52:54 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Simo Sorce <simo@redhat.com>
CC: linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: Strange cred expiry behavior
Date: Tue, 22 Oct 2013 12:52:53 +0000
Message-ID: <00287231-A3A3-42B8-AEC6-0472E50FE17A@netapp.com>
References: <85F2BCBA-9565-497F-BFF4-FEB29301D655@netapp.com>
 <DCD436E3-9464-4BFB-8C1A-19912522824D@netapp.com>
 <1382444401.9794.19.camel@willson.li.ssimo.org>
In-Reply-To: <1382444401.9794.19.camel@willson.li.ssimo.org>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks Simo!

I'll try doing the gss_inquire_creds() first and if that fixes things.

-dros

On Oct 22, 2013, at 8:20 AM, Simo Sorce <simo@redhat.com>
 wrote:

> On Mon, 2013-10-21 at 23:53 +0000, Weston Andros Adamson wrote:
>> I traced this behavior back to:
>> 
>> commit 302de786930a2c533068f9d8909a817b40f07c32
>> Author: Simo Sorce <simo@redhat.com>
>> Date:   Fri Apr 19 13:02:36 2013 -0400
>> 
>>    gssd: Allow GSSAPI to try to acquire credentials first.
>> 
>> 
>> And in particular:
>> 
>> -               for (dirname = ccachesearch; *dirname != NULL; dirname++) {
>> +               /* Try first to acquire credentials directly via GSSAPI */
>> +               err = gssd_acquire_user_cred(uid, &gss_cred);
>> +               if (!err)
>> +                       create_resp = create_auth_rpc_client(clp, &rpc_clnt, &auth, uid,
>> +                                                            AUTHTYPE_KRB5, gss_cred);
>> +               /* if create_auth_rplc_client fails try the traditional method of
>> +                * trolling for credentials */
>> +               for (dirname = ccachesearch; create_resp != 0 && *dirname != NULL; dirname++) {
>> 
>> A couple of things:
>> 
>>  - If I get rid of the "Try first to acquire credentials directly via
>> GSSAPI" part, expiry works as before.
> 
> Interesting, this call is necessary to make rpc.gssd work with gss-proxy
> and I had not experienced an issue so far. We can try to add a
> gss_inquire_cred() to gssd_acquire_user_cred() to force checking the
> credentials for expiration, as that check may be deferred in some cases
> in GSSAPI.
> 
>>  - It says "if create_auth_rplc_client fails try the traditional
>> method of trolling for credentials" but I see nothing that checks to
>> see if create_resp != 0 before falling back to the old method.
> 
> It's the check condition in the for loop, that's why I have not repeated
> it before the for loop.
> 
>>  I added this check and everything seems right (it doesn't fix the
>> expiry issue).
> 
> Yeah I didn't think it would.
> 
>> I should have some time tomorrow to look further at the expiry issue…
> 
> If you can add an explicit check with gss_inquire_creds() I think you'll
> get the right behavior.
> 
> Let me know if you need help.
> Simo.
> 
> -- 
> Simo Sorce * Red Hat, Inc * New York
> 

