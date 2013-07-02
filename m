Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:5394 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751641Ab3GBMaB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Jul 2013 08:30:01 -0400
Message-ID: <51D2C7C5.4090202@RedHat.com>
Date: Tue, 02 Jul 2013 08:29:57 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 2/3] krb5_util: don't give up on machine credential if
 hostname not available.
References: <20130603005219.20080.1927.stgit@notabene.brown> <20130603010021.20080.11239.stgit@notabene.brown> <51D1ACBE.7030608@RedHat.com> <20130702075650.63f72ca9@notabene.brown>
In-Reply-To: <20130702075650.63f72ca9@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/07/13 17:56, NeilBrown wrote:
> On Mon, 01 Jul 2013 12:22:22 -0400 Steve Dickson <SteveD@redhat.com> wrote:
> 
>> Sorry for getting into so late... I did an extraordinary amount
>> of travailing in June.... 
>>
>> On 02/06/13 21:00, Neil Brown wrote:
>>> krb5_util tries various different credential names in order to find
>>> the machine credential, not all of them use the full host name of the
>>> current host.
>>>
>>> So if getting the full host name fails, don't give up completely,
>>> still try the other options.
>>>
>>> Signed-off-by: NeilBrown <neilb@suse.de>
>>> ---
>>>  utils/gssd/krb5_util.c |    8 ++++++--
>>>  1 file changed, 6 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
>>> index 9ef80f0..5e84481 100644
>>> --- a/utils/gssd/krb5_util.c
>>> +++ b/utils/gssd/krb5_util.c
>>> @@ -825,8 +825,10 @@ find_keytab_entry(krb5_context context, krb5_keytab kt, const char *tgtname,
>>>  	myhostad[i+1] = 0;
>>>  
>>>  	retval = get_full_hostname(myhostname, myhostname, sizeof(myhostname));
>>> -	if (retval)
>>> -		goto out;
>>> +	if (retval) {
>>> +		/* Don't use myhostname */
>>> +		myhostname[0] = 0;
>>> +	}
>>>  
>>>  	code = krb5_get_default_realm(context, &default_realm);
>>>  	if (code) {
>>> @@ -883,6 +885,8 @@ find_keytab_entry(krb5_context context, krb5_keytab kt, const char *tgtname,
>>>  								myhostad,
>>>  								NULL);
>>>  			} else {
>>> +				if (!myhostname[0])
>>> +					continue;
>>>  				snprintf(spn, sizeof(spn), "%s/%s@%s",
>>>  					 svcnames[j], myhostname, realm);
>>>  				code = krb5_build_principal_ext(context, &princ,
>>>
>>>
>> At the end of day... This patch allows the machine cred to be used when
>> there is no DNS or /etc/hosts is empty (aka getaddrinfo() fails via 
>> the get_full_hostname() call).
>>
>> I'm thinking this is a good idea, but I'm a gnawing feeling this would
>> be open some type of security hole by using machine creds when they
>> should not be or they were not expected to be used...
>>
>> Am I being too paranoid???
> 
> Probably, but it is a good default position nonetheless.
> 
> This patch will only allow a machine credential to be used in the absence of
> an easily detected "full hostname" if a wild card machine credential is
> available.  And if such is available, it seems wrong not to use it.
> 
> If wildcard machine credentials were no expected to be used, it we seem
> strange to have them included in the keytab file.
> 
> So I cannot see any hole.
Fair enough... Thanks! 

steved.

