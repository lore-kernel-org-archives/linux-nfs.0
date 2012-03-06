Return-Path: linux-nfs-owner@vger.kernel.org
Received: from li9-11.members.linode.com ([67.18.176.11]:57484 "EHLO
	test.thunk.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751867Ab2CFPPt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Mar 2012 10:15:49 -0500
Date: Tue, 6 Mar 2012 10:15:43 -0500
From: "Ted Ts'o" <tytso@mit.edu>
To: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
Cc: linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, Fan Yong <yong.fan@whamcloud.com>,
        bfields@redhat.com, sandeen@redhat.com,
        Andreas Dilger <adilger@whamcloud.com>
Subject: Re: [PATCH 5 2/4] Return 32/64-bit dir name hash according to
 usage type
Message-ID: <20120306151543.GA32282@thunk.org>
References: <20120109132137.2616029.76288.stgit@localhost.localdomain>
 <20120109132148.2616029.68798.stgit@localhost.localdomain>
 <20120305155939.GE21356@thunk.org>
 <4F555CE5.7050401@itwm.fraunhofer.de>
 <20120306022838.GA24323@thunk.org>
 <4F55E01B.3060105@itwm.fraunhofer.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F55E01B.3060105@itwm.fraunhofer.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 06, 2012 at 10:59:55AM +0100, Bernd Schubert wrote:
> Arg, my bad, I introduced this issue when I converted from f_flags
> to f_mode, seems I forgot all of those above :(
> Hrm, I thought I had tested sufficiently, but obviously I did not :(
> Here's the test tool.
> http://www.pci.uni-heidelberg.de/tc/usr/bernd/downloads/test_seekdir/
> 
> While quickly looking, I think it only affects NFSv2, which I think
> I indeed didn't test. I only run tests for 32 bit and 64-bit user
> space and NFSv3. But yes, NFSv2 is an important test too. Not sure
> if I will find time for that today.

I think the problem case to worry about would have been on a 32-bit
NFS server (think embedded/bookshelf NAS servers) and NFSv3, since
that's where the inconsistency would have meant that hash2pos would
use the 32-bit codepath, but pos2maj_hash would use the 64-bit
codepath, and so then...  kablooey.

> Will send an updated version later on.

If it's just those changes, no worries, as I've already fixed up the
f_flags vs. f_mode issue in my copy of the patches.

Let me know if there are any other changes that you'd like to make or
issues that you've spotted.

						- Ted
