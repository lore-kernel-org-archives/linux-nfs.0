Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:64889 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751238Ab0KPXyR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Nov 2010 18:54:17 -0500
Received: by iwn35 with SMTP id 35so1427817iwn.19
        for <linux-nfs@vger.kernel.org>; Tue, 16 Nov 2010 15:54:16 -0800 (PST)
In-Reply-To: <4CE2E0FF.1080201@blub.net>
References: <4CE294DD.6010508@blub.net>
	<20101116183050.GC3971@fieldses.org>
	<4CE2E0FF.1080201@blub.net>
Date: Tue, 16 Nov 2010 18:54:15 -0500
Message-ID: <AANLkTi=pUkc5Dkd1A2fEKMB3Wm-cmtkKyXrt1bN7C=ZQ@mail.gmail.com>
Subject: Re: no_root_squash (and valid KRB root-ticket)
From: Kevin Coffman <kwc@citi.umich.edu>
To: Valentijn Sessink <valentyn@blub.net>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I believe the answer is to add a "static" mapping of some principal
name to be "root" locally on the server machine.

See the example in the idmap.conf man page (that comes with libnfsidmap).



On Tue, Nov 16, 2010 at 2:52 PM, Valentijn Sessink <valentyn@blub.net> wrote:
> Hi,
>
> Op 16-11-10 19:30, J. Bruce Fields schreef:
>>>
>>> I found that having "no_root_squash" on the server, having a valid
>>> Kerberos ticket for root@DOMAIN, does still not give you root rights on
>>> a share.
>>
>> This is between a linux client and server?
>
> Yes. Not a really recent one though, must be Ubuntu 10.04 server and client.
>
>> Are other kerberos principals mapped as you'd expect?
>
> Yes — it's on our production network, user ID's are mapped without a
> problem. While I'm typing this: I did not check what idmapd says; most of
> the users are in LDAP, while root is just a local user with a corresponding
> local user on the server. Can't think of a reason why this should bar root
> from using the share, but I will check that, tomorrow, just to be sure.
>
> V.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
