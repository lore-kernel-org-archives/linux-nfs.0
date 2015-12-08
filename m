Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:25238 "HELO
	discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751152AbbLHS35 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Dec 2015 13:29:57 -0500
From: Andrew W Elble <aweits@rit.edu>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC 2/4] nfs: machine credential support for additional operations
References: <1449067193-53310-1-git-send-email-aweits@rit.edu>
	<1449067193-53310-3-git-send-email-aweits@rit.edu>
	<CAHQdGtRfeNu5HUCOXi1sUDUnm1PtrzQm55RmN+4Et1vCJhxuYA@mail.gmail.com>
Date: Tue, 08 Dec 2015 13:29:56 -0500
In-Reply-To: <CAHQdGtRfeNu5HUCOXi1sUDUnm1PtrzQm55RmN+4Et1vCJhxuYA@mail.gmail.com>
	(Trond Myklebust's message of "Sun, 06 Dec 2015 13:47:29 -0800")
Message-ID: <m2h9js23q3.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust <trond.myklebust@primarydata.com> writes:

> On Wed, Dec 2, 2015 at 6:39 AM, Andrew Elble <aweits@rit.edu> wrote:
>> Allow LAYOUTRETURN and DELEGRETURN to use machine credentials if the
>> server supports it. Add request for OPEN_DOWNGRADE as the close path
>> also uses that.
>
> This patch looks fine, but can we please break it out of the series?
> There doesn't appear to be any dependency between this and the other
> patches, so it would be easier if I could just take it directly.

I'm fine with that - I have to (at least) do v2 on the rest, do you want
me to repost it separately?

Thanks,

Andy

-- 
Andrew W. Elble
aweits@discipline.rit.edu
Infrastructure Engineer, Communications Technical Lead
Rochester Institute of Technology
PGP: BFAD 8461 4CCF DC95 DA2C B0EB 965B 082E 863E C912
