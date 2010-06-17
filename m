From: Alexander Samad <alex-SGFoFqf0RKf0CCvOHzKKcA@public.gmane.org>
Subject: Re: Unable to mount with udp and vers=4 screws up uid/gid
Date: Thu, 17 Jun 2010 23:40:00 +1000
Message-ID: <AANLkTilzmN8dytZz-0YoeCNTxj5YvwF0D2X7t3vYp6jJ@mail.gmail.com>
References: <AANLkTinOBIbuEFGKbPHP95zhBtUifFpIRdxkJr8cXCvn@mail.gmail.com>
	<0AD72BA9-0C2D-45C7-9F80-24E407832938@samad.com.au>
	<20100615145529.GB17437@fieldses.org>
	<AANLkTilISmYCH2I_icpr_ka1C0wrvXLv7PFpAU925DXw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:52475 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759762Ab0FQNkF convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jun 2010 09:40:05 -0400
Received: by gxk21 with SMTP id 21so1656106gxk.19
        for <linux-nfs@vger.kernel.org>; Thu, 17 Jun 2010 06:40:03 -0700 (PDT)
In-Reply-To: <AANLkTilISmYCH2I_icpr_ka1C0wrvXLv7PFpAU925DXw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 17, 2010 at 10:52 PM, Alexander Samad <alex-SGFoFqf0RKf0CCvOHzKKcA@public.gmane.org> w=
rote:
> On Wed, Jun 16, 2010 at 12:55 AM, J. Bruce Fields <bfields@fieldses.o=
rg> wrote:
>> On Mon, Jun 14, 2010 at 08:34:06PM +1000, Alex Samad wrote:
>>>
>>>>
>>>
>>>> Hi
> [snip]
[snip]
>> =A0 =A0 =A0 =A0- check that the domain in /etc/idmapd.conf is set to=
 the same
>> =A0 =A0 =A0 =A0 =A0thing on client and server.
>
> yes

idmap wasn't being started, once I started it on both servers it seems
to be okay now with uid/gid


>
>> =A0 =A0 =A0 =A0- check that users have the same names on the client =
and on the
>> =A0 =A0 =A0 =A0 =A0server.
> yes, shared name space using ldap
>
> thanks hope that helps
>
>>
>> --b.
>>
> [snip]
>
