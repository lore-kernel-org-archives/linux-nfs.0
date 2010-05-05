From: Timo Aaltonen <timo.aaltonen-uOixanVlb7U@public.gmane.org>
Subject: RE: [PATCH] Check for AD style machine principal name
Date: Thu, 6 May 2010 01:33:41 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1005060131080.3282@deckard.hut.fi>
References: <1272290459-11335-1-git-send-email-timo.aaltonen@aalto.fi>  <560_1272392934_4BD72CE6_560_482_1_20100427182806.GP30729@fieldses.org>  <alpine.DEB.2.00.1005051934040.3282@deckard.hut.fi> <n2s4d569c331005051046t28cd5dch1e5dfe4a73b987bf@mail.gmail.com>
 <alpine.DEB.2.00.1005052347130.3282@deckard.hut.fi> <BF3BB6D12298F54B89C8DCC1E4073D80A24712@CORPUSMX50A.corp.emc.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-1;
	format=flowed
Cc: timo.aaltonen-uOixanVlb7U@public.gmane.org, kwc@citi.umich.edu, bfields@fieldses.org,
	linux-nfs@vger.kernel.org
To: Staubach_Peter@emc.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-3.hut.fi ([130.233.228.93]:50556 "EHLO smtp-3.hut.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753105Ab0EEWd6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 May 2010 18:33:58 -0400
In-Reply-To: <BF3BB6D12298F54B89C8DCC1E4073D80A24712-1Zg0zMUlrbd9m/dOYFj4Yjjd7nCn89gW@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 6 May 2010, Staubach_Peter@emc.com wrote:

> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner-fy+rA21nqHI@public.gmane.org=
rnel.org] On Behalf Of Timo Aaltonen
> Sent: Wednesday, May 05, 2010 6:16 PM
> To: Kevin Coffman
> Cc: J. Bruce Fields; linux-nfs@vger.kernel.org
> Subject: Re: [PATCH] Check for AD style machine principal name
>
> On Wed, 5 May 2010, Kevin Coffman wrote:
>
>> On Wed, May 5, 2010 at 12:53 PM, Timo Aaltonen <timo.aaltonen@aalto.=
fi> wrote:
>>>
>>> CC:ing the "new" list.
>>>
>>> On Tue, 27 Apr 2010, J. Bruce Fields wrote:
>>>
>>>> On Mon, Apr 26, 2010 at 05:00:59PM +0300, timo.aaltonen-uOixanVlb7U@public.gmane.org w=
rote:
>>>>>
>>>>> @@ -737,6 +737,26 @@ gssd_search_krb5_keytab(krb5_context context=
,
>>>>> krb5_keytab kt,
>>>>> =A0}
>>>>>
>>>>> =A0/*
>>>>> + * Convert the hostname to machine principal name as created
>>>>> + * by MS Active Directory.
>>>>> +*/
>>>>> +
>>>>> +static char *
>>>>> +hostname_to_adprinc(char *name)
>>>>> +{
>>>>> + =A0 =A0 =A0 int i =3D 0;
>>>>> + =A0 =A0 =A0 char *buf =3D strdup(name);
>>>>
>>>> We should handle the possible NULL return.
>>>
>>> How about not calling hostname_to_adprinc from find_keytab_entry un=
less
>>> myhostname is !=3D NULL?
>>
>> I think he meant that strdup() may fail, and return NULL.  That has =
to
>> be handled here, and a possible resulting NULL return from
>> host_to_adprinc() should also be handled below.
>
> Ahh.. ok so how about this:
>
> static char *
> hostname_to_adprinc(char *name)
> {
>         int i =3D 0;
>         int len =3D strlen(name);
>         char *buf;
>         if ((buf =3D malloc(len+1))) {
>
>> Doesn't this need to be "+2" since you are adding a '$' and a '\0' t=
o the end of the string, neither of which is included in the strlen() c=
alculation?

Yep, you're right. Shouldn't adding to the buffer fail then, when the=20
malloc leaves the string short?

>                 strcpy(buf, name);
>                 while(i < len) {
>                         buf[i] =3D toupper(buf[i]);
>                         i++;
>                 }
>
>> Instead of copying name to buf and then converting the characters in=
 buf to uppercase, why not copy and convert in one loop?

This
                          buf[i] =3D toupper(name[i]);

works fine, thanks :)

--=20
Timo Aaltonen
Systems Specialist
IT Services, Aalto University
