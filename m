Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:48760 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752347AbbC3P2O (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Mar 2015 11:28:14 -0400
Date: Mon, 30 Mar 2015 11:28:11 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] debugfs: debugfs_create_* shouldn't be checking
 permissions
Message-ID: <20150330152811.GD6901@fieldses.org>
References: <20150330142310.GB6901@fieldses.org>
 <20150330151638.GA13616@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150330151638.GA13616@kroah.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 30, 2015 at 05:16:38PM +0200, Greg Kroah-Hartman wrote:
> On Mon, Mar 30, 2015 at 10:23:10AM -0400, J. Bruce Fields wrote:
> > From: "J. Bruce Fields" <bfields@redhat.com>
> > 
> > Subject: [PATCH] debugfs: debugfs_create_* shouldn't be checking permissions
> 
> Side-note, why are you putting the Subject: again here in the body of
> the patch?

Just sloppy cut-and-pasting from git-format-patch output, apologies!

--b.
