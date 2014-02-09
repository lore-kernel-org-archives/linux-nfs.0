Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44126 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751290AbaBICJk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 8 Feb 2014 21:09:40 -0500
Date: Sat, 8 Feb 2014 21:09:33 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Steven Whitehouse <swhiteho@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: memory corruption after "Fix race when checking i_size on direct
 i/o read"
Message-ID: <20140209020933.GA23163@fieldses.org>
References: <20140208204522.GG8801@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140208204522.GG8801@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Feb 08, 2014 at 03:45:22PM -0500, bfields wrote:
> I'm getting warnings about corruption of the kmalloc-32 slab on an nfs
> server while running some regression tests.
> 
> A bisect lands on 9fe55eea7e4b444bafc42fa0000cc2d1d2847275 "Fix race
> when checking i_size on direct i/o read".  Is there any known problem
> here?
> 
> It doesn't reproduce immediately and it's possible I could have made a
> mistake on the bisect.

Argh, apologies, yes--I'm able to reproduce the corruption before that
commit.  I'll keep looking....

--b.
