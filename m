Return-Path: linux-nfs-owner@vger.kernel.org
Received: from merlin.infradead.org ([205.233.59.134]:43994 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752267Ab3EFIwL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 May 2013 04:52:11 -0400
Date: Mon, 6 May 2013 10:50:25 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Colin Cross <ccross@android.com>
Cc: linux-kernel@vger.kernel.org, Trond Myklebust <Trond.Myklebust@netapp.com>,
        Len Brown <len.brown@intel.com>, Pavel Machek <pavel@ucw.cz>,
        "Rafael J. Wysocki" <rjw@sisk.pl>, Ingo Molnar <mingo@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mandeep Singh Baines <msb@chromium.org>,
        Paul Walmsley <paul@pwsan.com>, Al Viro <viro@zeniv.linux.org.uk>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Oleg Nesterov <oleg@redhat.com>, linux-nfs@vger.kernel.org,
        linux-pm@vger.kernel.org, netdev@vger.kernel.org,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Tejun Heo <tj@kernel.org>, Ben Chan <benchan@chromium.org>
Subject: Re: [PATCH 1/2] freezer: add unsafe versions of freezable helpers
Message-ID: <20130506085025.GB13861@dyad.programming.kicks-ass.net>
References: <1367615050-3894-1-git-send-email-ccross@android.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1367615050-3894-1-git-send-email-ccross@android.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 03, 2013 at 02:04:09PM -0700, Colin Cross wrote:
> NFS calls the freezable helpers with locks held, which is unsafe
> and caused lockdep warnings when 6aa9707 "lockdep: check that no
> locks held at freeze time" was applied (reverted in dbf520a).
> Add new *_unsafe versions of the helpers that will not run the
> lockdep test when 6aa9707 is reapplied, and call them from NFS.

Am I the only one that would like a bit more information about why NFS does
this and why we need to work around it?

>From replies in this thread I surmise its got something to do with hard NFS
mounts. And I suppose I could go apply google to lkml and try and find the
previous discussion, but really this should be in the Changelog.
