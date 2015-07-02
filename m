Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:33134 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752475AbbGBHuH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Jul 2015 03:50:07 -0400
MIME-Version: 1.0
In-Reply-To: <20150702041046.GG17109@ZenIV.linux.org.uk>
References: <20150621211213.GA18732@ZenIV.linux.org.uk>
	<5587F943.3040006@samsung.com>
	<20150701062752.GC17109@ZenIV.linux.org.uk>
	<55939BE3.6040902@samsung.com>
	<20150701082753.GD17109@ZenIV.linux.org.uk>
	<5593A7A0.6050400@samsung.com>
	<20150701085507.GE17109@ZenIV.linux.org.uk>
	<5593CE37.4070307@samsung.com>
	<20150701184408.GF17109@ZenIV.linux.org.uk>
	<20150702032042.GA32613@ZenIV.linux.org.uk>
	<20150702041046.GG17109@ZenIV.linux.org.uk>
Date: Thu, 2 Jul 2015 10:50:05 +0300
Message-ID: <CAPAsAGzZVy3-D4J1ZGsUZU4RRQ36NtprZg_Uvfi5=46=1_rpWA@mail.gmail.com>
Subject: Re: running out of tags in 9P (was Re: [git pull] vfs part 2)
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        LKML <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>,
        Eric Van Hensbergen <ericvh@gmail.com>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[repeating, since my previous email didn't reach mailing lists]

2015-07-02 7:10 GMT+03:00 Al Viro <viro@zeniv.linux.org.uk>:
>> It should be easy to confirm - in p9_client_prepare_req() add
>>               if (WARN_ON_ONCE(tag != (u16)tag)) {
>>                       p9_idpool_put(tag, c->tagpool);
>>                       return ERR_PTR(-ENOMEM);
>>               }
>> right after
>>                 tag = p9_idpool_get(c->tagpool);
>>                 if (tag < 0)
>>                         return ERR_PTR(-ENOMEM);
>>
>> and see if it triggers.  I'm not sure if failing with ENOMEM is the
>> right response (another variant is to sleep there until the pile
>> gets cleaned or until we get killed), and WARN_ON_ONCE() is definitely
>> not for the real work, but it will do for confirming that this is what
>> we are hitting.
>

Apparently, I'm seeing something else. That WARN_ON_ONCE didn't trigger.
