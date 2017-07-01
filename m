Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:54188 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751389AbdGAQG0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 1 Jul 2017 12:06:26 -0400
Date: Sat, 1 Jul 2017 12:06:25 -0400
To: stable@vger.kernel.org
Cc: linux-nfs@vger.kernel.org
Subject: please cherry pick nfs commit df807fffaabd for stable
Message-ID: <20170701160625.GA1851@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I have a report of divide error on 4.11.5-200.fc25.x86_64:

	https://bugzilla.kernel.org/show_bug.cgi?id=196235

It looks like

	df807fffaabd "NFSv4.x/callback: Create the callback service
		through svc_create_pooled"

should have had a stable cc.

I believe it's needed on any kernel containing bb6aeba736ba "NFSv4.x:
Switch to using svc_set_num_threads() to manage the callback threads"
(which went in to 4.9).

--b.
