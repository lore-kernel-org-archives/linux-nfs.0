Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-fx0-f46.google.com ([209.85.161.46]:34831 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756742Ab1LBOlW convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Dec 2011 09:41:22 -0500
Received: by faaq16 with SMTP id q16so2081824faa.19
        for <linux-nfs@vger.kernel.org>; Fri, 02 Dec 2011 06:41:21 -0800 (PST)
MIME-Version: 1.0
Reply-To: tigran.mkrtchyan@desy.de
In-Reply-To: <4ED39F2D.7050508@RedHat.com>
References: <CAGue13qasD7m+dj3PdA+p5jfJQU_Eq0r+Z9QqtvOSnadFmWJeg@mail.gmail.com>
	<20111123201345.GA1044@fieldses.org>
	<4ED39F2D.7050508@RedHat.com>
Date: Fri, 2 Dec 2011 15:41:21 +0100
Message-ID: <CAGue13qyZPwTF1erSPwj5iaiwOOq8NGdpedS0BeMZ3JCFSveYw@mail.gmail.com>
Subject: Re: nfs-utils and libnfsidmap
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 28, 2011 at 3:48 PM, Steve Dickson <SteveD@redhat.com> wrote:
> On 11/23/2011 03:13 PM, J. Bruce Fields wrote:
>> On Wed, Nov 23, 2011 at 08:54:06PM +0100, Tigran Mkrtchyan wrote:
>>> Hi All,
>>>
>>> today was tracing a bug in nfs-utils/libnfsidmap and after a log
>>> debugging located it and
>>> finally realized that it's already fixed by Steve Dickson (
>>> http://git.linux-nfs.org/?p=steved/nfs-utils.git;a=commit;h=d22ef3f525d71b565fcc688557273a6cabeeb71a
>>> ). Nevertheless during
>>> this procedure it turned out that there is quite some code duplicated
>>> between nfs-utils and
>>> libnfsidmap.
>>>
>>> Questions:
>>>    a) why nfs-utils duplicates some part of libnfsidmap and still depends o it
>>>    b) is there readon for code duplication? Licensing or so
>>>    c) what ww need to do to get rid of duplication
>>>
>>> I expect the answer of 'c' will contain something like time and man power.
>>> I am volunteering to to pend some time on it.
>>
>> I doubt there's any real reason for duplication.
> Just curious as to what code we are talking about...

for example
  nfs-utils/support/nfs/conffile.c  => libnfsidmap/cfg.c
  nfs-utils/utils/idmapd/queue.h =>  libnfsidmap/queue.h

probably some other files as well.

Tigran.

>
>>
>> Probably libnfsidmap should be part of nfs-utils, actually.
> I guess we could roll the libnfsidmap git tree into the nfs-utils
> tree... if that make senses... It probably would simply things..
>
>>
>> And maybe we don't need it at all--the original reason to split out
>> libnfsidmap was to share the code with libacl, so the posix getfacl
>> command could do v4->posix acl mapping, but those patches never made it
>> upstream.
> So you don't think this will every happen?
>
> steved.
>
>>
>> --b.
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
