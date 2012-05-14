Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35927 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932720Ab2ENXyf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 May 2012 19:54:35 -0400
Date: Mon, 14 May 2012 19:54:32 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andreas Dilger <adilger@dilger.ca>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "Theodore Ts'o" <tytso@mit.edu>,
        "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH] ext4: turn on i_version updates by default
Message-ID: <20120514235432.GA3199@fieldses.org>
References: <20120514140618.GA29902@fieldses.org>
 <9124E59E-2479-4C32-A528-3237B48DEC01@dilger.ca>
 <1337036918.2522.32.camel@lade.trondhjem.org>
 <A0359961-B147-4343-BFA3-E82F38C6700B@dilger.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <A0359961-B147-4343-BFA3-E82F38C6700B@dilger.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 14, 2012 at 05:33:04PM -0600, Andreas Dilger wrote:
> I said as much in another reply - that once i_version is used on
> a filesystem, it should be made "sticky" (i.e. permanently enabled
> for that filesystem).  However, until that time it shouldn't be
> enabled just because it might one day be used.
> 
> Even better than just blindly bumping the i_version on every change,
> it would be better to have users of i_version (i.e. knfsd) flag the
> inode with "needs i_version update" then read the version.  When the
> filesystem/VFS bumps i_version the next time it can clear this flag
> and not update i_version again until after the next time i_version
> is actually used.

I really don't want to do anything more complicated than necessary.

What would be the worst-case test for the extra inode dirtying, so we
can see what the numbers actually are?

--b.
