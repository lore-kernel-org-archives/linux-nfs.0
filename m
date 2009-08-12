Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mrout2-b.corp.re1.yahoo.com ([69.147.107.21]:25689 "EHLO
	mrout2-b.corp.re1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751893AbZHLUJY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Aug 2009 16:09:24 -0400
Received: from enemycanmeet.champ.corp.yahoo.com (enemycanmeet.champ.corp.yahoo.com [10.74.90.165])
	by mrout2-b.corp.re1.yahoo.com (8.13.8/8.13.8/y.out) with ESMTP id n7CJtxTB043431
	for <linux-nfs@vger.kernel.org>; Wed, 12 Aug 2009 12:55:59 -0700 (PDT)
Received: from enemycanmeet.champ.corp.yahoo.com (localhost.localdomain [127.0.0.1])
	by enemycanmeet.champ.corp.yahoo.com (8.13.8/8.13.8) with ESMTP id n7CJtj49020147
	for <linux-nfs@vger.kernel.org>; Wed, 12 Aug 2009 14:55:45 -0500
Received: (from qbarnes@localhost)
	by enemycanmeet.champ.corp.yahoo.com (8.13.8/8.13.8/Submit) id n7CJtjMx020146
	for linux-nfs@vger.kernel.org; Wed, 12 Aug 2009 14:55:45 -0500
Date: Wed, 12 Aug 2009 14:55:44 -0500
From: Quentin Barnes <qbarnes+nfs@yahoo-inc.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Old 2.6.18 NFS attribute cache bug on SMP kernels
Message-ID: <20090812195544.GA19990@yahoo-inc.com>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I've been doing some NFSv3 performance testing in preparation for
moving a multi-threaded app from RHEL4 (2.6.9) to RHEL5 (2.6.18).
In testing, noticed about an 8% decrease in overall performance of
the app when on RHEL5 which was troubling.

The NFS file system used by the app is mounted "nocto".  I
eventually isolated the drop in performance to the attribute cache.
When I disabled the use of the attribute cache or disabled extra
processors on an SMP system, performance came back.  It was actually
_faster_ to go out over the network to the NFS server and do the
GETATTR on an open(2) than it was to reuse the attributes in the
cache on an SMP system!

I wrote a simple multi-threaded program that all it would do is
fork multiple copies then just open and close files as quickly as
possible.  When doing just open and closes, performance is down by a
huge amount.  The test, when _not_ using the attribute cache, gets a
huge speed boost -- 300%-2000% or even more.

On a "nocto" mounted file system with an 8 processor SMP box,
performance would go from 176k open calls per second with only one
process running, to 10k/s with two processes, to just crawling along
with 3k/s for four processes.  If I dynamically turn off all but
one processor on the box, performance is _much_ better and drops
linearly (as expected with a purely CPU bound jobs): 258k/s with one
process, to 130k/s with two processes, to 65k/s with four processes.

Notice that the curve in SP mode (258k/s vs. 176k/s) starts out much
better even for the 1 process case.  That doesn't make any sense to
me.  If it was simple lock contention, I would expect performance for
one process running to be the same in both cases.

I reproduced this problem on Intel 6600's, L5320',s, and Core2Duo's
running x86_64 kernels.  I had someone try it on AMD systems and
they apparently didn't see it, so it might be just related to Intel
processors, but I can't be positive.  It happens with a plain
kernel.org 2.6.18.8 kernel, so it's not a RHEL5-specific issue.  The
good news is the problem does not happen with a generic 2.6.19.7
kernel, so the problem was addressed in the next release.

In comparing the 2.6.18.8 and 2.6.19.7 NFS source trees, there's
been a lot of changes.  What I would like to know is: in the past
was this an explicitly know issue; and does anyone know what
changeset or changesets between these two kernels might have fixed
this issue?

Quentin
