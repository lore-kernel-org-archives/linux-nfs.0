Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f50.google.com ([209.85.212.50]:33205 "EHLO
	mail-vb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757636Ab3EFWLE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 May 2013 18:11:04 -0400
Received: by mail-vb0-f50.google.com with SMTP id w16so3414097vbb.9
        for <linux-nfs@vger.kernel.org>; Mon, 06 May 2013 15:11:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFwbXk_r-4p37YiMTQj2HNRA94xohr6DADuQXpHsKSA7NQ@mail.gmail.com>
References: <1367615050-3894-1-git-send-email-ccross@android.com>
	<20130506065605.6e5ed5e2@tlielax.poochiereds.net>
	<CAMbhsRQsFT2j_CuPL45J03itymcp3PNP8ckt3fAAo+hzavNrbw@mail.gmail.com>
	<20130506174336.447d0d75@tlielax.poochiereds.net>
	<CAMbhsRQP+NFwn8C9-mXUVCZNi_oE+TCK1L1NgdGUA_CTw0eiMA@mail.gmail.com>
	<CA+55aFwbXk_r-4p37YiMTQj2HNRA94xohr6DADuQXpHsKSA7NQ@mail.gmail.com>
Date: Mon, 6 May 2013 15:11:02 -0700
Message-ID: <CAMbhsRRiWGrvqTKX_wcQM9v-k9nRuash54uHjXPY+HO4z4K6Dg@mail.gmail.com>
Subject: Re: [PATCH 1/2] freezer: add unsafe versions of freezable helpers
From: Colin Cross <ccross@android.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Jeff Layton <jlayton@redhat.com>, lkml <linux-kernel@vger.kernel.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Len Brown <len.brown@intel.com>, Pavel Machek <pavel@ucw.cz>,
        "Rafael J. Wysocki" <rjw@sisk.pl>,
        Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mandeep Singh Baines <msb@chromium.org>,
        Paul Walmsley <paul@pwsan.com>, Al Viro <viro@zeniv.linux.org.uk>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Oleg Nesterov <oleg@redhat.com>, linux-nfs <linux-nfs@vger.kernel.org>,
        Linux PM list <linux-pm@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>, Tejun Heo <tj@kernel.org>,
        Ben Chan <benchan@chromium.org>, Steve French <smfrench@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 6, 2013 at 2:58 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Mon, May 6, 2013 at 2:54 PM, Colin Cross <ccross@android.com> wrote:
>>>
>>> There are many other possibilities for other codepaths that end up in
>>> wait_for_response(). Once we get a solution in place for NFS, we'll
>>> need to do something very similar for CIFS.
>>
>> Makes sense, I will add CIFS to the patch.  Would you prefer it in the
>> same or separate patches.
>
> Quite frankly, is it worth resurrecting these patches at all?
>
> The only things it actually complained about are not worth the pain
> fixing and are getting explicitly not warned about - is there any
> reason to believe the patches are worth maintaining and the extra
> complexity is worth it?

There was at least one real other case caught when this patch was
applied: https://lkml.org/lkml/2013/3/4/390.  Tejun asked that I
resurrect it because I'm adding some additional APIs similar to
freezable_schedule() and he wanted to make sure they didn't get used
improperly in the future.
