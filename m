Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:33840 "EHLO
	mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756191AbbE2Pan convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 May 2015 11:30:43 -0400
MIME-Version: 1.0
In-Reply-To: <CAHQdGtRKLnMbB6Z5w7MCnONujHH2uBnx4VUrTL1GGfWTNwurRQ@mail.gmail.com>
References: <cover.1429868795.git.agruenba@redhat.com>
	<9fee05c37be52b8f8fcd5df05f391af9e3d820e8.1429868795.git.agruenba@redhat.com>
	<CAHQdGtSUjeV_5UNFdgMQXXbRq2Fs+JTc6t-Dy2y1-hS4c49GOA@mail.gmail.com>
	<CAHpGcMKn1khdNTk=MFS7vFgLCHmxX2fVTJanertXT+Zj_BnAKA@mail.gmail.com>
	<CAHQdGtRKLnMbB6Z5w7MCnONujHH2uBnx4VUrTL1GGfWTNwurRQ@mail.gmail.com>
Date: Fri, 29 May 2015 17:30:42 +0200
Message-ID: <CAHpGcMK=RSOhb2f5K+czLmbAd6FJr9LgLRp6GhMbvGxJFpQioQ@mail.gmail.com>
Subject: Re: [RFC v3 37/45] nfs/sunrpc: No more encode and decode function
 pointer casting
From: =?UTF-8?Q?Andreas_Gr=C3=BCnbacher?= <andreas.gruenbacher@gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2015-05-29 2:37 GMT+02:00 Trond Myklebust <trond.myklebust@primarydata.com>:
> On Thu, May 28, 2015 at 7:40 PM, Andreas Grünbacher
> <andreas.gruenbacher@gmail.com> wrote:
>> 2015-05-29 1:11 GMT+02:00 Trond Myklebust <trond.myklebust@primarydata.com>:
>>> How is this even remotely relevant to ACL functionality, and why does
>>> it deserve to bypass the NFS tree?
>>
>> I've posted this to the linux-nfs mailing list for review among
>> others, how is that
>> bypassing the NFS tree? Would you prefer those things sent to you personally
>> as well?
>
> No. I'm saying that changes that affect the core RPC code should not
> be going through external trees as part of an external feature; they
> should go through the maintainer trees.

I agree, none of that is going to get merged directly.

Andreas
