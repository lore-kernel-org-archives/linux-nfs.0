Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:16944 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756543Ab3EFWF6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 May 2013 18:05:58 -0400
Date: Mon, 6 May 2013 18:05:17 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Colin Cross <ccross@android.com>, lkml <linux-kernel@vger.kernel.org>,
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
Subject: Re: [PATCH 1/2] freezer: add unsafe versions of freezable helpers
Message-ID: <20130506180517.070bc3e2@tlielax.poochiereds.net>
In-Reply-To: <CA+55aFwbXk_r-4p37YiMTQj2HNRA94xohr6DADuQXpHsKSA7NQ@mail.gmail.com>
References: <1367615050-3894-1-git-send-email-ccross@android.com>
	<20130506065605.6e5ed5e2@tlielax.poochiereds.net>
	<CAMbhsRQsFT2j_CuPL45J03itymcp3PNP8ckt3fAAo+hzavNrbw@mail.gmail.com>
	<20130506174336.447d0d75@tlielax.poochiereds.net>
	<CAMbhsRQP+NFwn8C9-mXUVCZNi_oE+TCK1L1NgdGUA_CTw0eiMA@mail.gmail.com>
	<CA+55aFwbXk_r-4p37YiMTQj2HNRA94xohr6DADuQXpHsKSA7NQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 6 May 2013 14:58:31 -0700
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Mon, May 6, 2013 at 2:54 PM, Colin Cross <ccross@android.com> wrote:
> >>
> >> There are many other possibilities for other codepaths that end up in
> >> wait_for_response(). Once we get a solution in place for NFS, we'll
> >> need to do something very similar for CIFS.
> >
> > Makes sense, I will add CIFS to the patch.  Would you prefer it in the
> > same or separate patches.
> 
> Quite frankly, is it worth resurrecting these patches at all?
> 
> The only things it actually complained about are not worth the pain
> fixing and are getting explicitly not warned about - is there any
> reason to believe the patches are worth maintaining and the extra
> complexity is worth it?
> 
>            Linus

Well, these problems are worth the pain of fixing, I think. It's just
going to take us a while to get there since it involves some
significant surgery.

As to whether the warnings themselves are worthwhile now that we're
excluding the most egregious offenders from them, I don't much care
either way.

-- 
Jeff Layton <jlayton@redhat.com>
