Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f47.google.com ([209.85.213.47]:36222 "EHLO
	mail-vk0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755048AbcB1WL6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 28 Feb 2016 17:11:58 -0500
Received: by mail-vk0-f47.google.com with SMTP id c3so118100934vkb.3
        for <linux-nfs@vger.kernel.org>; Sun, 28 Feb 2016 14:11:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <56CC3174.2060207@gmail.com>
References: <56B770B6.7040803@gmail.com>
	<56B77262.7090107@gmail.com>
	<CAHc6FU5__xbKm4mg8+fK_ZW5ZYsDoQcYBBvQg573Eq4ERDsROw@mail.gmail.com>
	<56C0F23C.7030902@gmail.com>
	<CAHc6FU4CCrcrA6=oCiq2A5rGd9CCGELaTZq6tGpmd2jcV_Zp4A@mail.gmail.com>
	<56CA2EEB.9080504@gmail.com>
	<CAHc6FU46vO8NM3cvFH7b8X7U9R+m6wcYj8EQKVnSQkiY3Q051A@mail.gmail.com>
	<56CC3174.2060207@gmail.com>
Date: Sun, 28 Feb 2016 23:11:57 +0100
Message-ID: <CAHc6FU4eOzNg0Tfb-29uQD9r1AzwZhZPMZnRnbjyYpkQxm=Cxw@mail.gmail.com>
Subject: Re: richacl(7) man page review comments
From: Andreas Gruenbacher <agruenba@redhat.com>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        linux-ext4 <linux-ext4@vger.kernel.org>,
        XFS Developers <xfs@oss.sgi.com>, lkml <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-cifs@vger.kernel.org, Linux API <linux-api@vger.kernel.org>,
        Dave Chinner <david@fromorbit.com>,
        Christoph Hellwig <hch@infradead.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        Andreas Dilger <adilger@dilger.ca>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 23, 2016 at 11:16 AM, Michael Kerrisk (man-pages)
<mtk.manpages@gmail.com> wrote:
> On 02/22/2016 03:46 PM, Andreas Gruenbacher wrote:
>> On Sun, Feb 21, 2016 at 10:40 PM, Michael Kerrisk (man-pages) <mtk.manpages@gmail.com> wrote:
>>> I've once more pulled from the latest git; here's some more comments.
>>
>> thanks again. I've updated the repo with your changes.
>
> Thanks!
>
> [...]
>
>>> I'm going to play the broken record :-)
>>>
>>> Could we start with just a few simple examples already, and build up
>>> over future iterations of this page?
>>
>> Yes, as soon as I'll get to it :)
>
> Sure. But, to press the point home, I'm interested to do further
> review, but I feel like the lack of examples is limiting my ability to
> understand what's going on and deepen the feedback that I provide in
> future iterations. So, start please, even if only starting small :-).

I've added a richaclex(7) examples man page now. What did I miss to explain?

Thanks,
Andreas
