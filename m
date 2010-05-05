From: Timo Aaltonen <timo.aaltonen-uOixanVlb7U@public.gmane.org>
Subject: Re: [PATCH] Check for AD style machine principal name
Date: Wed, 5 May 2010 19:53:33 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1005051934040.3282@deckard.hut.fi>
References: <1272290459-11335-1-git-send-email-timo.aaltonen@aalto.fi> <560_1272392934_4BD72CE6_560_482_1_20100427182806.GP30729@fieldses.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-3.hut.fi ([130.233.228.93]:50863 "EHLO smtp-3.hut.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753359Ab0EERX5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 May 2010 13:23:57 -0400
In-Reply-To: <560_1272392934_4BD72CE6_560_482_1_20100427182806.GP30729@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


CC:ing the "new" list.

On Tue, 27 Apr 2010, J. Bruce Fields wrote:

> On Mon, Apr 26, 2010 at 05:00:59PM +0300, timo.aaltonen-uOixanVlb7U@public.gmane.org wrote:
>> @@ -737,6 +737,26 @@ gssd_search_krb5_keytab(krb5_context context, krb5_keytab kt,
>>  }
>>
>>  /*
>> + * Convert the hostname to machine principal name as created
>> + * by MS Active Directory.
>> +*/
>> +
>> +static char *
>> +hostname_to_adprinc(char *name)
>> +{
>> +	int i = 0;
>> +	char *buf = strdup(name);
>
> We should handle the possible NULL return.

How about not calling hostname_to_adprinc from find_keytab_entry unless 
myhostname is != NULL?

>> +	int len = strlen(name);
>> +	while(i < len) {
>> +		buf[i] = toupper(buf[i]);
>> +		i++;
>> +	}
>> +	buf[i++] = '$';
>> +	buf[i] = 0;
>
> This is past the end of the buffer.  Maybe you want buf to be
> strlen(name)+1?

Ok, so:
         char *buf = malloc(sizeof(name)+1);
 	buf = strdup(name);
 	.
 	.
works, and should be ok?

>> @@ -812,6 +836,35 @@ find_keytab_entry(krb5_context context, krb5_keytab kt, const char *hostname,
>>  			break;
>>  		if (strcmp(realm, default_realm) == 0)
>>  			tried_default = 1;
>> +		/* First try the Active Directory style machine principal */
>> +		code = krb5_build_principal_ext(context, &princ,
>> +						strlen(realm),
>> +						realm,
>> +						strlen(adprinc),
>> +						adprinc,
>> +						NULL);
>> +		if (code) {
>> +			k5err = gssd_k5_err_msg(context, code);
>> +			printerr(1, "%s while building principal for "
>> +				 "'%s@%s'\n", k5err,
>> +				 adprinc, realm);
>> +			continue;
>
> Is there an infinite loop here?

Not to my knowledge, it's basically the same chunk of code copied from 
a few lines below, modified to suit the adprinc.


-- 
Timo Aaltonen
Systems Specialist
IT Services, Aalto University
