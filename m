From: Timo Aaltonen <timo.aaltonen-uOixanVlb7U@public.gmane.org>
Subject: Re: [PATCH] Check for AD style machine principal name
Date: Thu, 6 May 2010 01:15:48 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1005052347130.3282@deckard.hut.fi>
References: <1272290459-11335-1-git-send-email-timo.aaltonen@aalto.fi>  <560_1272392934_4BD72CE6_560_482_1_20100427182806.GP30729@fieldses.org>  <alpine.DEB.2.00.1005051934040.3282@deckard.hut.fi>
 <n2s4d569c331005051046t28cd5dch1e5dfe4a73b987bf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-15;
	format=flowed
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Kevin Coffman <kwc@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-2.hut.fi ([130.233.228.92]:49347 "EHLO smtp-2.hut.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752109Ab0EEWQK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 May 2010 18:16:10 -0400
In-Reply-To: <n2s4d569c331005051046t28cd5dch1e5dfe4a73b987bf-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 5 May 2010, Kevin Coffman wrote:

> On Wed, May 5, 2010 at 12:53 PM, Timo Aaltonen <timo.aaltonen@aalto.f=
i> wrote:
>>
>> CC:ing the "new" list.
>>
>> On Tue, 27 Apr 2010, J. Bruce Fields wrote:
>>
>>> On Mon, Apr 26, 2010 at 05:00:59PM +0300, timo.aaltonen-uOixanVlb7U@public.gmane.org wr=
ote:
>>>>
>>>> @@ -737,6 +737,26 @@ gssd_search_krb5_keytab(krb5_context context,
>>>> krb5_keytab kt,
>>>> =A0}
>>>>
>>>> =A0/*
>>>> + * Convert the hostname to machine principal name as created
>>>> + * by MS Active Directory.
>>>> +*/
>>>> +
>>>> +static char *
>>>> +hostname_to_adprinc(char *name)
>>>> +{
>>>> + =A0 =A0 =A0 int i =3D 0;
>>>> + =A0 =A0 =A0 char *buf =3D strdup(name);
>>>
>>> We should handle the possible NULL return.
>>
>> How about not calling hostname_to_adprinc from find_keytab_entry unl=
ess
>> myhostname is !=3D NULL?
>
> I think he meant that strdup() may fail, and return NULL.  That has t=
o
> be handled here, and a possible resulting NULL return from
> host_to_adprinc() should also be handled below.

Ahh.. ok so how about this:

static char *
hostname_to_adprinc(char *name)
{
         int i =3D 0;
         int len =3D strlen(name);
         char *buf;
         if ((buf =3D malloc(len+1))) {
                 strcpy(buf, name);
                 while(i < len) {
                         buf[i] =3D toupper(buf[i]);
                         i++;
                 }
                 buf[i++] =3D '$';
                 buf[i] =3D 0;
                 return buf;
         }
         return NULL;
}

and then adding 'if (adprinc !=3D NULL) { ... }' to the while loop in=20
find_keytab_entry. That passes my tests.


>>>> @@ -812,6 +836,35 @@ find_keytab_entry(krb5_context context, krb5_=
keytab
>>>> kt, const char *hostname,
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (strcmp(realm, default_realm) =3D=
=3D 0)
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tried_default =3D 1=
;
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* First try the Active Directory st=
yle machine principal
>>>> */
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 code =3D krb5_build_principal_ext(co=
ntext, &princ,
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 strlen(realm),
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 realm,
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 strlen(adprinc),
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 adprinc,
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 NULL);
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (code) {
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 k5err =3D gssd_k5_er=
r_msg(context, code);
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printerr(1, "%s whil=
e building principal for "
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"=
'%s@%s'\n", k5err,
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0a=
dprinc, realm);
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>>>
>>> Is there an infinite loop here?
>>
>> Not to my knowledge, it's basically the same chunk of code copied fr=
om a few
>> lines below, modified to suit the adprinc.
>
> The chunk you copied was within a for() loop.  You are calling
> continue within the while(1) loop.

Ok, so 'continue' was extra, whoops..


--=20
Timo Aaltonen
Systems Specialist
IT Services, Aalto University
