Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:5908 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754129Ab3JVQWS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Oct 2013 12:22:18 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Simo Sorce <simo@redhat.com>
CC: "<SteveD@redhat.com>" <SteveD@redhat.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] gssd: validate cred in gssd_acquire_user_cred
Date: Tue, 22 Oct 2013 16:22:17 +0000
Message-ID: <E7C76283-6DA1-453B-A386-6C1A2DDC7653@netapp.com>
References: <1382450675-14636-1-git-send-email-dros@netapp.com>
 <1382452919.9794.63.camel@willson.li.ssimo.org>
 <0A5F8F19-4730-4D1A-86A5-5533D758AC23@netapp.com>
 <1382458386.9794.89.camel@willson.li.ssimo.org>
In-Reply-To: <1382458386.9794.89.camel@willson.li.ssimo.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 22, 2013, at 12:13 PM, Simo Sorce <simo@redhat.com> wrote:

> On Tue, 2013-10-22 at 16:03 +0000, Weston Andros Adamson wrote:
>> On Oct 22, 2013, at 10:41 AM, Simo Sorce <simo@redhat.com> wrote:
>> 
>>> On Tue, 2013-10-22 at 10:04 -0400, Weston Andros Adamson wrote:
>>>> Call gss_inquire_cred after gssd_acquire_krb5_cred check for expired
>>>> credentials.
>>>> 
>>>> This fixes a recent regression (since 302de786930a2c533068f9d8909a817b40f07c32)
>>>> that causes the user's ticket cache to grow unbounded with expired service
>>>> tickets when the user's credentials expire.
>>>> 
>>>> To reproduce this issue:
>>>> 
>>>> - mount kerberos nfs export
>>>> - kinit for a short lifetime (ie "kinit -l 1m")
>>>> - run a job that opens a file and writes for more than the lifetime
>>>> - run klist a few times after expiry and see the list grow, ie:
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
>>>> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
>>>> ---
>>>> utils/gssd/krb5_util.c | 7 +++++++
>>>> 1 file changed, 7 insertions(+)
>>>> 
>>>> diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
>>>> index c6e52fd..ec5db83 100644
>>>> --- a/utils/gssd/krb5_util.c
>>>> +++ b/utils/gssd/krb5_util.c
>>>> @@ -1405,6 +1405,13 @@ gssd_acquire_user_cred(uid_t uid, gss_cred_id_t *gss_cred)
>>>> 
>>>> 	ret = gssd_acquire_krb5_cred(name, gss_cred);
>>>> 
>>>> +	/* force validation of cred to check for expiry */
>>>> +	if (ret == 0) {
>>>> +		if (gss_inquire_cred(min_stat, gss_cred, NULL, NULL,
>>>> +				     NULL, NULL) != GSS_S_COMPLETE)
>>>> +			ret = -1;
>>>> +	}
>>>> +
>>>> 	maj_stat = gss_release_name(&min_stat, &name);
>>>> 	return ret;
>>>> }
>>> 
>>> A good start, but given you are inquiring creds, then I think it would
>>> totally make sense to pass in a uint32_t for the 4th argument
>>> (lifetime), and check if there is "enough".
>> 
>> Well, from my perspective gssd already gives enough info for you to know what's going on, i.e.:
>> 
>> getting credentials for client with uid 1749600001 for server zero.apikia.fake
>> CC '/run/user/1749600001/krb5cc' being considered, with preferred realm 'APIKIA.FAKE'
>> CC 'DIR:/run/user/1749600001/krb5cc' is expired or corrupt
>> WARNING: Failed to create krb5 context for user with uid 1749600001 for server zero.apikia.fake
>> doing error downfall
>> 
>> And it's obvious from the NFS layer as EKEYEXPIRED gets passed through as the error.
>> 
>>> 
>>> For example, if it returns a lifetime of 1 second should we continue ?
>>> There is a fat chance that it will fail later on.
>> 
>> I think how we handle this now (without the regression this fixes) is fine.  I really don't think users/ admins want to enable verbose debugging in gssd to see this - they should be able to tell what happened when the caller gets an expired cred.
>> 
>>> 
>>> I think we should at least log it if the credential we are trying to use
>>> turns out to be really close to expiring, no ? It may save some gray
>>> hairs to server administrators trying to find out what is going wrong
>>> (like it happened to you :)
>> 
>> Well, it was obvious to me what was happening when the keys expired - what was not obvious was why the tkt cache was growing unbounded with service tickets that were *never* valid (the regression this patch fixes).
>> 
>> I suppose we could do something more, but I don't really see a reason to.
> 
> 
> you are probably right,
> 
> Reviewed-by: Simo Sorce <simo@redhat.com>


Cool, thanks for the help! I'm sure it would have taken me a long time to track down gss_inquire_cred() on my own.

I'm definitely open to improving the debuggability of gssd, so if you really think we need some warning during some window before the cred expires, let's work with the list to figure out how that should look.

-dros


