Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ve0-f169.google.com ([209.85.128.169]:59323 "EHLO
	mail-ve0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756782Ab3EFV6c (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 May 2013 17:58:32 -0400
MIME-Version: 1.0
In-Reply-To: <CAMbhsRQP+NFwn8C9-mXUVCZNi_oE+TCK1L1NgdGUA_CTw0eiMA@mail.gmail.com>
References: <1367615050-3894-1-git-send-email-ccross@android.com>
	<20130506065605.6e5ed5e2@tlielax.poochiereds.net>
	<CAMbhsRQsFT2j_CuPL45J03itymcp3PNP8ckt3fAAo+hzavNrbw@mail.gmail.com>
	<20130506174336.447d0d75@tlielax.poochiereds.net>
	<CAMbhsRQP+NFwn8C9-mXUVCZNi_oE+TCK1L1NgdGUA_CTw0eiMA@mail.gmail.com>
Date: Mon, 6 May 2013 14:58:31 -0700
Message-ID: <CA+55aFwbXk_r-4p37YiMTQj2HNRA94xohr6DADuQXpHsKSA7NQ@mail.gmail.com>
Subject: Re: [PATCH 1/2] freezer: add unsafe versions of freezable helpers
From: Linus Torvalds <torvalds@linux-foundation.org>
To: Colin Cross <ccross@android.com>
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
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 6, 2013 at 2:54 PM, Colin Cross <ccross@android.com> wrote:
>>
>> There are many other possibilities for other codepaths that end up in
>> wait_for_response(). Once we get a solution in place for NFS, we'll
>> need to do something very similar for CIFS.
>
> Makes sense, I will add CIFS to the patch.  Would you prefer it in the
> same or separate patches.

Quite frankly, is it worth resurrecting these patches at all?

The only things it actually complained about are not worth the pain
fixing and are getting explicitly not warned about - is there any
reason to believe the patches are worth maintaining and the extra
complexity is worth it?

           Linus
