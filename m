Return-Path: linux-nfs-owner@vger.kernel.org
Received: from partagas.dragonet.es ([217.70.240.130]:43662 "EHLO
	partagas.dragonet.es" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754703Ab2B1XW6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Feb 2012 18:22:58 -0500
Message-ID: <4F4D61B6.5090304@steve-ss.com>
Date: Wed, 29 Feb 2012 00:22:30 +0100
From: steve <steve@steve-ss.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org
Subject: Re: POSIX acls over nfs4
References: <4F40053A.3090301@steve-ss.com> <4F412E2F.9070200@steve-ss.com> <4F45E78E.8050501@steve-ss.com> <20120223063913.5736a5b1@tlielax.poochiereds.net> <4F4628B8.90401@steve-ss.com> <20120223144053.GA25010@fieldses.org> <4F465C3A.9080802@steve-ss.com> <20120223154215.GA26706@fieldses.org> <4F466467.3030506@steve-ss.com> <4F489999.30909@steve-ss.com> <20120228200524.GE2723@fieldses.org>
In-Reply-To: <20120228200524.GE2723@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/28/2012 09:05 PM, J. Bruce Fields wrote:
> On Sat, Feb 25, 2012 at 09:19:37AM +0100, steve wrote:
>> On 23/02/12 17:08, steve wrote:
>>> On 02/23/2012 04:42 PM, J. Bruce Fields wrote:
>>>>>> First, if you want an ace on a directory to be inherited by files and
>>>>>> directories created under that directory, make sure you're setting
>>>>>> the f
>>>>>> and d flags (see nfs4_getfacl -H).
>>>>>>
>>>>>> Second, there's a umask problem: posix acl inheritance overrides the
>>>>>> umask, but nfs4 acl inheritance isn't doing that. (The client combines
>>>>>> the create mode and the umask and sets both together, there's no way
>>>>>> for
>>>>>> the server to even tell what the umask is.)
>>>>>>
>>>>>> (We should do something about this if we can: maybe modifying the
>>>>>> client
>>>>>> to scan the directory acl for any inheritable aces and leaving out the
>>>>>> umask if they're found? It has the obvious race, but I seem to recall
>>>>>> we live with that in the v3 case. Or maybe there's something more
>>>>>> clever, but this comes up every now and then and I can't remember a
>>>>>> better solution.)
>>>>>>
>> Hi everyone
>>
>> This really is a show stopper for us.
>>
>> Would it be possible to give users the choice of being able to
>> disable nfs4 acls so we can fall back to POSIX or nt acls? Or at
>> least until the nfs4 team have had time to consider the situation?
> The NFSv4 protocol has no support for posix acls, so this isn't an
> option; possibly you're best off with v3 for some reason.  (Why the
> migration to v4?)
We are authenticating against Samba4, so our domain user accounts are 
under Kerberos. We could wait for the s4 cifs fileserver and winbind to 
be ready but would rather stick with nfs for our Linux clients. Simple 
reason being that it beats cifs on speed, especially when the lan is busy.

Is there an option to turn off the nfs4 acl's? I see that there is a -o 
noacl mount option but it seems to have no effect for us.

Guys, basically we don't know where to turn next. We have this issue 
open here, and on the samba and openSUSE lists. Is there anyway we can 
get together to thrash this out?

Thanks so much for replying.
Cheers,
Steve pp the Spanish team at lcb


>
> --b.
>
>> Mounting with -o nofacl in the hope that the POSIX acl set on the
>> unmounted directory would take effect, seems to have no effect.
>>
>> What I'm doing at the moment is scanning the unmounted directory
>> every few seconds using 'find' and changing the files to g+rw:-(
>>
>> Thanks,
>> Steve
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

