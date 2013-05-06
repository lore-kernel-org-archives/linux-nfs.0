Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f174.google.com ([209.85.161.174]:64836 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758311Ab3EFWO7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 May 2013 18:14:59 -0400
Date: Mon, 6 May 2013 15:14:20 -0700
From: Tejun Heo <tj@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Colin Cross <ccross@android.com>, Jeff Layton <jlayton@redhat.com>,
        lkml <linux-kernel@vger.kernel.org>,
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
        netdev <netdev@vger.kernel.org>, Ben Chan <benchan@chromium.org>,
        Steve French <smfrench@gmail.com>
Subject: Re: [PATCH 1/2] freezer: add unsafe versions of freezable helpers
Message-ID: <20130506221420.GH800@mtj.dyndns.org>
References: <1367615050-3894-1-git-send-email-ccross@android.com>
 <20130506065605.6e5ed5e2@tlielax.poochiereds.net>
 <CAMbhsRQsFT2j_CuPL45J03itymcp3PNP8ckt3fAAo+hzavNrbw@mail.gmail.com>
 <20130506174336.447d0d75@tlielax.poochiereds.net>
 <CAMbhsRQP+NFwn8C9-mXUVCZNi_oE+TCK1L1NgdGUA_CTw0eiMA@mail.gmail.com>
 <CA+55aFwbXk_r-4p37YiMTQj2HNRA94xohr6DADuQXpHsKSA7NQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CA+55aFwbXk_r-4p37YiMTQj2HNRA94xohr6DADuQXpHsKSA7NQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello, Linus.

On Mon, May 06, 2013 at 02:58:31PM -0700, Linus Torvalds wrote:
> Quite frankly, is it worth resurrecting these patches at all?
> 
> The only things it actually complained about are not worth the pain
> fixing and are getting explicitly not warned about - is there any
> reason to believe the patches are worth maintaining and the extra
> complexity is worth it?

It might not be too useful for nfs but Colin has a patchset spreading
the use of the freezable schedules in a number of places in an attempt
to reduce freeze latency for android, which includes introducing a lot
of schedule_*_freezable() constructs, so I think we need these
warnings one way or the other so that we don't end up with more
problems like nfs currently has.

Thakns.

-- 
tejun
