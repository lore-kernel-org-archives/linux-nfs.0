Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:45662 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751338AbeBWQDv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 23 Feb 2018 11:03:51 -0500
Date: Fri, 23 Feb 2018 11:03:50 -0500
To: linux-nfs@vger.kernel.org
Subject: xfstests EBUSY on generic/32, generic/247
Message-ID: <20180223160350.GF15876@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Starting somewhere between v4.15-rc1 and v4.16-rc1, I'm getting sporadic
failures: either on generic/32, with "pread64: Device or resource busy",
or generic/247, on "mmap: Device or resource busy".  Anyone else aware
of this?

Annoyingly, I haven't been able to reproduce yet by running just those
tests, I only reproduce reliably with a 1-2 hour test run.  I'll see if
I can narrow it down any more....

--b.
