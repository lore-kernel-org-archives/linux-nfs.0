From: Kevin Coffman <kwc@citi.umich.edu>
Subject: Re: [PATCH] Check for AD style machine principal name
Date: Wed, 5 May 2010 13:46:55 -0400
Message-ID: <n2s4d569c331005051046t28cd5dch1e5dfe4a73b987bf@mail.gmail.com>
References: <1272290459-11335-1-git-send-email-timo.aaltonen@aalto.fi>
	 <560_1272392934_4BD72CE6_560_482_1_20100427182806.GP30729@fieldses.org>
	 <alpine.DEB.2.00.1005051934040.3282@deckard.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Timo Aaltonen <timo.aaltonen-uOixanVlb7U@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f198.google.com ([209.85.211.198]:38966 "EHLO
	mail-yw0-f198.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751670Ab0EERq5 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 May 2010 13:46:57 -0400
Received: by ywh36 with SMTP id 36so2371069ywh.4
        for <linux-nfs@vger.kernel.org>; Wed, 05 May 2010 10:46:56 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1005051934040.3282-9o+TK994UVukEuhtYYxXtw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 5, 2010 at 12:53 PM, Timo Aaltonen <timo.aaltonen-uOixanVlb7U@public.gmane.org>=
 wrote:
>
> CC:ing the "new" list.
>
> On Tue, 27 Apr 2010, J. Bruce Fields wrote:
>
>> On Mon, Apr 26, 2010 at 05:00:59PM +0300, timo.aaltonen-uOixanVlb7U@public.gmane.org wro=
te:
>>>
>>> @@ -737,6 +737,26 @@ gssd_search_krb5_keytab(krb5_context context,
>>> krb5_keytab kt,
>>> =A0}
>>>
>>> =A0/*
>>> + * Convert the hostname to machine principal name as created
>>> + * by MS Active Directory.
>>> +*/
>>> +
>>> +static char *
>>> +hostname_to_adprinc(char *name)
>>> +{
>>> + =A0 =A0 =A0 int i =3D 0;
>>> + =A0 =A0 =A0 char *buf =3D strdup(name);
>>
>> We should handle the possible NULL return.
>
> How about not calling hostname_to_adprinc from find_keytab_entry unle=
ss
> myhostname is !=3D NULL?

I think he meant that strdup() may fail, and return NULL.  That has to
be handled here, and a possible resulting NULL return from
host_to_adprinc() should also be handled below.

>>> + =A0 =A0 =A0 int len =3D strlen(name);
>>> + =A0 =A0 =A0 while(i < len) {
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 buf[i] =3D toupper(buf[i]);
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 i++;
>>> + =A0 =A0 =A0 }
>>> + =A0 =A0 =A0 buf[i++] =3D '$';
>>> + =A0 =A0 =A0 buf[i] =3D 0;
>>
>> This is past the end of the buffer. =A0Maybe you want buf to be
>> strlen(name)+1?
>
> Ok, so:
> =A0 =A0 =A0 =A0char *buf =3D malloc(sizeof(name)+1);
> =A0 =A0 =A0 =A0buf =3D strdup(name);
> =A0 =A0 =A0 =A0.
> =A0 =A0 =A0 =A0.
> works, and should be ok?
>
>>> @@ -812,6 +836,35 @@ find_keytab_entry(krb5_context context, krb5_k=
eytab
>>> kt, const char *hostname,
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (strcmp(realm, default_realm) =3D=
=3D 0)
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tried_default =3D 1;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* First try the Active Directory sty=
le machine principal
>>> */
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 code =3D krb5_build_principal_ext(con=
text, &princ,
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 strlen(realm),
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 realm,
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 strlen(adprinc),
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 adprinc,
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 NULL);
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (code) {
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 k5err =3D gssd_k5_err=
_msg(context, code);
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printerr(1, "%s while=
 building principal for "
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"'=
%s@%s'\n", k5err,
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ad=
princ, realm);
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>>
>> Is there an infinite loop here?
>
> Not to my knowledge, it's basically the same chunk of code copied fro=
m a few
> lines below, modified to suit the adprinc.

The chunk you copied was within a for() loop.  You are calling
continue within the while(1) loop.
