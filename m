From: Alexander Samad <alex-SGFoFqf0RKf0CCvOHzKKcA@public.gmane.org>
Subject: Re: Unable to mount with udp and vers=4 screws up uid/gid
Date: Thu, 17 Jun 2010 22:52:33 +1000
Message-ID: <AANLkTilISmYCH2I_icpr_ka1C0wrvXLv7PFpAU925DXw@mail.gmail.com>
References: <AANLkTinOBIbuEFGKbPHP95zhBtUifFpIRdxkJr8cXCvn@mail.gmail.com>
	<0AD72BA9-0C2D-45C7-9F80-24E407832938@samad.com.au>
	<20100615145529.GB17437@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:52197 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752732Ab0FQMwe convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jun 2010 08:52:34 -0400
Received: by iwn9 with SMTP id 9so6747866iwn.19
        for <linux-nfs@vger.kernel.org>; Thu, 17 Jun 2010 05:52:33 -0700 (PDT)
In-Reply-To: <20100615145529.GB17437@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 16, 2010 at 12:55 AM, J. Bruce Fields <bfields@fieldses.org=
> wrote:
> On Mon, Jun 14, 2010 at 08:34:06PM +1000, Alex Samad wrote:
>>
>>>
>>
>>> Hi
[snip]
>
> I'm confused; which are you using, v3 or v4?
Sorry lots of information.

I have tried several combination
a) udp, vers=3D3
b) tcp, vers=3D3
c) udp, vers=3D4
d) tcp,vers=3D4


>
[snip]
>
> I thought you said above that you *couldn't* mount v4? =A0Apologies, =
I may
> just be sleep-deprived, but could you take just a *single* problem an=
d
> describe it =A0carefully from start to finish?

from the above table of combinations, currently only b & d mount with
any of my clients and the nfs servers.

Lets make this about option D, vers=3D4, tcp


>
>>> ls -l
>>> drwxrwsr-x =A02 4294967294 4294967294 4.1k Oct 25 =A02009 Funnies
>
> Probably an idmapping problem:
>
> =A0 =A0 =A0 =A0- check that the domain in /etc/idmapd.conf is set to =
the same
> =A0 =A0 =A0 =A0 =A0thing on client and server.

yes

> =A0 =A0 =A0 =A0- check that users have the same names on the client a=
nd on the
> =A0 =A0 =A0 =A0 =A0server.
yes, shared name space using ldap

thanks hope that helps

>
> --b.
>
[snip]
