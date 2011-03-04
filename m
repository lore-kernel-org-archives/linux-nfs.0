Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:48381 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752435Ab1CDTsp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Mar 2011 14:48:45 -0500
Received: from mail-iy0-f174.google.com (mail-iy0-f174.google.com [209.85.210.174])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p24JmijE023117
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Fri, 4 Mar 2011 11:48:44 -0800
Received: by iyb26 with SMTP id 26so2195516iyb.19
        for <linux-nfs@vger.kernel.org>; Fri, 04 Mar 2011 11:48:43 -0800 (PST)
In-Reply-To: <20110304193325.GB21260@fieldses.org>
References: <1299257053-13175-1-git-send-email-nhorman@tuxdriver.com>
 <20110304171320.GA19496@fieldses.org> <20110304184505.GB10083@hmsreliant.think-freely.org>
 <20110304193325.GB21260@fieldses.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 4 Mar 2011 11:48:23 -0800
Message-ID: <AANLkTimpX6JPWyPgB6vcZ8TuQ5gj9aPcJ9OCK186n5Nk@mail.gmail.com>
Subject: Re: [Security] [PATCH] nfs4: Ensure that ACL pages sent over NFS were
 not allocated from the slab
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Neil Horman <nhorman@tuxdriver.com>, linux-nfs@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>, security@kernel.org,
        Jeff Layton <jlayton@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Mar 4, 2011 at 11:33 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
>
> So I assumed the slab allocator would hold a reference to the page like
> any other user would, in which case the tcp code could take a second
> reference of its own.

So the reason that wouldn't work is simple: the reference is obviously
at a page level, but slab doles out allocations on its own level.

What does that mean? Imagine if the network layer takes a ref on the
page, but then the original user does a "kfree()". The _page_ would
stay around (we have a ref from it - but so does the slab allocator),
but the thing is, the slab allocator will release and then re-use the
slab entry.

So the "hold a reference to the page" doesn't actually _help_. The
problem isn't the page going away, it's the smaller slab-allocation
being reused for something else - so the page-level ref would be
useless.

So page-level references really only do work with page allocators.
They don't know about the allocation patterns within a page that slab
does.

                     Linus
