Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40098 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751452AbaBHUpX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 8 Feb 2014 15:45:23 -0500
Date: Sat, 8 Feb 2014 15:45:22 -0500
To: Steven Whitehouse <swhiteho@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: memory corruption after "Fix race when checking i_size on direct i/o
 read"
Message-ID: <20140208204522.GG8801@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm getting warnings about corruption of the kmalloc-32 slab on an nfs
server while running some regression tests.

A bisect lands on 9fe55eea7e4b444bafc42fa0000cc2d1d2847275 "Fix race
when checking i_size on direct i/o read".  Is there any known problem
here?

It doesn't reproduce immediately and it's possible I could have made a
mistake on the bisect.

I'll verify and try to narrow down the reproducer.

--b.
