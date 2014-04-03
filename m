Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44471 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752937AbaDCRYc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Apr 2014 13:24:32 -0400
Date: Thu, 3 Apr 2014 13:24:31 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Boaz Harrosh <openosd@gmail.com>
Cc: NeilBrown <neilb@suse.de>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: Should exportfs/mountd cope with case-insensitive directory
 names.
Message-ID: <20140403172431.GB5884@fieldses.org>
References: <20140403164652.5d7770ad@notabene.brown>
 <20140403130909.GA24700@fieldses.org>
 <533D8629.10907@gmail.com>
 <20140403171625.GA5884@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140403171625.GA5884@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 03, 2014 at 01:16:25PM -0400, J. Bruce Fields wrote:
> In the presence of bind mounts it's definitely possible for two
> different paths to reach the same directory.
> 
> I don't know if that's actually a problem here....

Without testing: if we've got the same filesystem mounted at /foo/bar
and /foo/baz, but only export /foo/bar, will this change make that
export show up at /foo/baz as well?

(Since we'll now consider /foo/bar and /foo/baz to match where
previously they didn't?)

--b.
