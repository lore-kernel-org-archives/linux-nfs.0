Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:40892 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755803Ab1LGOJi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Dec 2011 09:09:38 -0500
Message-ID: <4EDF737A.2080400@panasas.com>
Date: Wed, 7 Dec 2011 16:08:58 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: <tao.peng@emc.com>
CC: <bergwolf@gmail.com>, <bhalevy@tonian.com>, <Trond.Myklebust@netapp.com>,
        <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH-RESEND 4/4] pnfsblock: do not ask for layout in pg_init
References: <1322888194-3039-1-git-send-email-bergwolf@gmail.com> <4ED62857.7090804@tonian.com> <CA+a=Yy5BYoxVWM+4C6ORex5aOZcLAbUmhY6XE=wBsreGVG7GAA@mail.gmail.com> <4ED6D5D8.9010801@panasas.com> <F19688880B763E40B28B2B462677FBF805E5043E4B@MX09A.corp.emc.com> <4ED7BA55.8010200@panasas.com> <F19688880B763E40B28B2B462677FBF805E5043F8B@MX09A.corp.emc.com>
In-Reply-To: <F19688880B763E40B28B2B462677FBF805E5043F8B@MX09A.corp.emc.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/02/2011 06:59 AM, tao.peng@emc.com wrote:
>>
> I'm sorry but I don't get it... How do you count the first contiguous
> chunk in .pg_init? All you know at .pg_init is an empty io desc and
> an nfs page. Are you going to scan the radix tree and find the next
> page that write_cache_pages is going to flush out? I don't really
> think anyone will agree on it... Please look into the second part of
> your solution and then you'll see why I am worried that it may never
> get done.> 
> Best Regards,
> Tao
> 

Rrrr, one thing I cannot do is make some one understand.

I guess I'll have to do it my self. It's so simple I'm go'ne cry.

I have more pressed things on my plate then fix broken blocks servers
but you are forcing my hands. The last code you sent is not acceptable
because it is totally not usable by objects and files (segments).

Give me a week. Not that it should take longer then an hour but
because I have burning matters to attend to first.

Boaz

>> Boaz
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

