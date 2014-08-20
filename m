Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f175.google.com ([209.85.220.175]:46761 "EHLO
	mail-vc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753122AbaHTX1R (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Aug 2014 19:27:17 -0400
Received: by mail-vc0-f175.google.com with SMTP id ik5so9858331vcb.20
        for <linux-nfs@vger.kernel.org>; Wed, 20 Aug 2014 16:27:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <87ppfvrdux.fsf@x220.int.ebiederm.org>
References: <1408217806-25877-1-git-send-email-xiyou.wangcong@gmail.com>
	<87ppfvrdux.fsf@x220.int.ebiederm.org>
Date: Wed, 20 Aug 2014 19:27:15 -0400
Message-ID: <CAHQdGtS41PsfH5SKr2kcpUjnb7QL4CPFey1zSasXmHbhnZqtEQ@mail.gmail.com>
Subject: Re: [PATCH v2] nfs: fix kernel warning when removing proc entry
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Dan Aloni <dan@kernelim.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 20, 2014 at 12:20 AM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
> Cong Wang <xiyou.wangcong@gmail.com> writes:
>
>> I saw the following kernel warning:
>
> Cong thanks for finding and tracking this.  I was clearly asleep at the
> switch when I was testing my fix to the nfs client code :(
>
> I have applied this patch and will push it to Linus after it has a
> little bit to sit in linux-next.
>

This is precisely _WHY_ it is supposed to go through the maintainer,
and not through arbitrary namespace trees. I'm tired of the namespace
folks pushing crap and just assuming that a "Cc:" is OK. A "Cc:
maintainer" means this is an RFC, not something that is to be
committed.

Trond
