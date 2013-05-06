Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f45.google.com ([209.85.213.45]:61172 "EHLO
	mail-yh0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754882Ab3EFTD1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 May 2013 15:03:27 -0400
Date: Mon, 6 May 2013 11:55:13 -0700
From: Tejun Heo <tj@kernel.org>
To: Colin Cross <ccross@android.com>
Cc: linux-kernel@vger.kernel.org, Trond Myklebust <Trond.Myklebust@netapp.com>,
        Len Brown <len.brown@intel.com>, Pavel Machek <pavel@ucw.cz>,
        "Rafael J. Wysocki" <rjw@sisk.pl>,
        Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mandeep Singh Baines <msb@chromium.org>,
        Paul Walmsley <paul@pwsan.com>, Al Viro <viro@zeniv.linux.org.uk>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Oleg Nesterov <oleg@redhat.com>, linux-nfs@vger.kernel.org,
        linux-pm@vger.kernel.org, netdev@vger.kernel.org,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Ben Chan <benchan@chromium.org>
Subject: Re: [PATCH 1/2] freezer: add unsafe versions of freezable helpers
Message-ID: <20130506185513.GA800@mtj.dyndns.org>
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
> 
> Signed-off-by: Colin Cross <ccross@android.com>

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun
