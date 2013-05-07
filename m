Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qe0-f50.google.com ([209.85.128.50]:57858 "EHLO
	mail-qe0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756846Ab3EGSMo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 May 2013 14:12:44 -0400
Date: Tue, 7 May 2013 11:12:37 -0700
From: Tejun Heo <tj@kernel.org>
To: Colin Cross <ccross@android.com>
Cc: linux-kernel@vger.kernel.org, Pavel Machek <pavel@ucw.cz>,
        "Rafael J. Wysocki" <rjw@sisk.pl>,
        Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mandeep Singh Baines <msb@chromium.org>,
        Oleg Nesterov <oleg@redhat.com>, linux-nfs@vger.kernel.org,
        linux-pm@vger.kernel.org, netdev@vger.kernel.org,
        Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH v2 00/10] optimize freezing tasks by reducing task wakeups
Message-ID: <20130507181237.GE5531@mtj.dyndns.org>
References: <1367884221-20462-1-git-send-email-ccross@android.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1367884221-20462-1-git-send-email-ccross@android.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

On Mon, May 06, 2013 at 04:50:05PM -0700, Colin Cross wrote:
> On slow cpus the large number of task wakeups and context switches
> triggered by freezing and thawing tasks can take a significant amount
> of cpu time.  This patch series reduces the amount of work done during
> freezing tasks by avoiding waking up tasks that are already in a freezable
> state.

For the whole series,

 Acked-by: Tejun Heo <tj@kernel.org>

Thanks a lot!

-- 
tejun
