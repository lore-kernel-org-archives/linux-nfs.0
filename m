Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53207 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751364AbaC2A6b (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 28 Mar 2014 20:58:31 -0400
Date: Fri, 28 Mar 2014 20:58:31 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] NFSD: Re-initialize fh_post/pre_saved between two
 operations
Message-ID: <20140329005831.GO6041@fieldses.org>
References: <533299E9.6010806@gmail.com>
 <20140328211920.GD6041@fieldses.org>
 <5335FAB2.8050404@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <5335FAB2.8050404@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Mar 29, 2014 at 06:41:54AM +0800, Kinglong Mee wrote:
> 
> 
> 于 2014/3/29 05:19, J. Bruce Fields 写道:
> >On Wed, Mar 26, 2014 at 05:12:09PM +0800, Kinglong Mee wrote:
> >>Testing NFS4.0 by pynfs, I got some messeages as,
> >>"nfsd: inode locked twice during operation."
> >
> >Thanks for looking into this.  I agree that we should clear fh_pre_saved
> >and fh_post_saved between compound ops.
> >
> >This is kind of non-obvious, though, so I think it would be worth moving
> >these two assignments to a little helper function (how about
> >"fh_clear_wcc_data()" for a name?) and adding a comment with the
> >definition of the function, explaining why we need it.
> 
> That's great.
> Thanks for your advice.
> 
> >
> >>When one compound RPC contains two or more SETATTR operation
> >>for one filehandle,the second SETATTR will cause the message.
> >
> >Also worth noting that this affects any op that locks the filehandle
> >(e.g. a compound with two LINK ops would probably trigger the same
> >warning.)
> 
> Yes, that's right.

OK, thanks, I'll assume you're sending a revised patch.

--b.
