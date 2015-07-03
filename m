Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:35992 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755143AbbGCT41 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Jul 2015 15:56:27 -0400
MIME-Version: 1.0
In-Reply-To: <20150703150000.GS17109@ZenIV.linux.org.uk>
References: <CAPAsAGzZVy3-D4J1ZGsUZU4RRQ36NtprZg_Uvfi5=46=1_rpWA@mail.gmail.com>
	<20150702075932.GI17109@ZenIV.linux.org.uk>
	<CAPAsAGzJW1C-4rd9myZOsiA9dLp2d420PTePaguK=y2RWjrz2A@mail.gmail.com>
	<20150702082529.GJ17109@ZenIV.linux.org.uk>
	<20150702084208.GK17109@ZenIV.linux.org.uk>
	<55952C6D.50805@samsung.com>
	<20150702164332.GL17109@ZenIV.linux.org.uk>
	<20150702164926.GN17109@ZenIV.linux.org.uk>
	<55964593.1070507@samsung.com>
	<20150703094210.GR17109@ZenIV.linux.org.uk>
	<20150703150000.GS17109@ZenIV.linux.org.uk>
Date: Fri, 3 Jul 2015 22:56:25 +0300
Message-ID: <CAPAsAGxPQ9=DQCn17We3HMGPCbiqbmKo4C5zco0UBQ58i=usfw@mail.gmail.com>
Subject: Re: [PATCH] forgetting to cancel request in interrupted zero-copy 9P
 RPC (was Re: [git pull] vfs part 2)
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

2015-07-03 18:00 GMT+03:00 Al Viro <viro@zeniv.linux.org.uk>:
> Could you verify that the patch below deals with your setup as well?
> If it does, I'm going to put it into tonight's pull request, after I get
> some sleep...  Right now I'm about to crawl in direction of bed - 25 hours
> of uptime is a bit too much... ;-/
>

Works for me.
Tested-by: Andrey Ryabinin <a.ryabinin@samsung.com>
