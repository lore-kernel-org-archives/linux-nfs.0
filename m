Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ye0-f201.google.com ([209.85.213.201]:53901 "EHLO
	mail-ye0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932273Ab3EFXuY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 May 2013 19:50:24 -0400
Received: by mail-ye0-f201.google.com with SMTP id m14so447953yen.2
        for <linux-nfs@vger.kernel.org>; Mon, 06 May 2013 16:50:23 -0700 (PDT)
From: Colin Cross <ccross@android.com>
To: linux-kernel@vger.kernel.org
Cc: Pavel Machek <pavel@ucw.cz>, "Rafael J. Wysocki" <rjw@sisk.pl>,
        Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mandeep Singh Baines <msb@chromium.org>,
        Colin Cross <ccross@android.com>, Oleg Nesterov <oleg@redhat.com>,
        linux-nfs@vger.kernel.org, linux-pm@vger.kernel.org,
        netdev@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>,
        Tejun Heo <tj@kernel.org>
Subject: [PATCH v2 00/10] optimize freezing tasks by reducing task wakeups
Date: Mon,  6 May 2013 16:50:05 -0700
Message-Id: <1367884221-20462-1-git-send-email-ccross@android.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On slow cpus the large number of task wakeups and context switches
triggered by freezing and thawing tasks can take a significant amount
of cpu time.  This patch series reduces the amount of work done during
freezing tasks by avoiding waking up tasks that are already in a freezable
state.

The first 4 patches reintroduce 6aa9707099c (lockdep: check that no locks
held at freeze time) which was reverted in dbf520a9d7d4, and fix up the
known callers with locks held in NFS and CIFS to skip the lockdep check
for now.  The lockdep check will warn any future incorrect users of the
freezable helpers.

The fifth patch reduces the wasted time in try_to_freeze_tasks() by
starting with a 1 ms sleep during the first loop and backing off
up to an 8 ms sleep if all tasks are not frozen.

The sixth patch modifies the freeze_task() function to skip tasks
that have set the PF_FREEZER_SKIP flag by calling freezer_do_not_count().
These tasks will not enter the refrigerator during the suspend/resume
cycle unless they woken up by something else, in which case they will
enter the refrigerator in freezer_count() before they access any
resources that would not be available in suspend or deadlock with
another freezing/frozen task.

The rest of the series adds a few more freezable helpers and converts the
top call sites that userspace tasks are usually blocked at to freezable
helpers.  The list of call sites was collected on a Nexus 10 (ARM Exynos
5250 SoC), but all the top call sites other than binder show up at the
top of the list on Ubuntu x86-64 as well.

This series cuts the time for freezing tasks from 50 ms to 5 ms when
the cpu speed is locked at its lowest setting (200MHz), and reduces
the number of context switches and restarted syscalls from 1000 to
25.

v2 moves the skip check to freeze_task(), and expands the commit
messages.

v3 adds the patches to reintroduce the lockdep check to this patchset,
adds a patch to convert the freezable helpers to static inlines when
possible, and splits the patch that adds the new helpers out of the one
that converts the existing helpers to use freezer_do_not_count.
