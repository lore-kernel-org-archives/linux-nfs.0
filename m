Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:41650 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932708AbeCSO1O (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Mar 2018 10:27:14 -0400
Date: Mon, 19 Mar 2018 10:27:13 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        NeilBrown <neilb@suse.com>
Subject: Re: [PATCH] vfs: remove unnecessary fl_owner_t typedef
Message-ID: <20180319142713.GA24699@fieldses.org>
References: <20180317184840.GA32322@fieldses.org>
 <20180317191415.GQ30522@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180317191415.GQ30522@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Mar 17, 2018 at 07:14:15PM +0000, Al Viro wrote:
> On Sat, Mar 17, 2018 at 02:48:40PM -0400, J. Bruce Fields wrote:
> > This is a pretty simple patch that touches a lot of files.  What's the
> > procedure for handling patches like this?  I haven't had to do this
> > before.
> 
> I'm not sure it's a good idea.  We want it opaque - if anything, I would
> prefer to have anything mistakenly passing it to a function that takes
> a pointer scream like hell at build time.  The current variant doesn't
> have such protection, but it can at least be grepped for.  void * can't. 

OK; dropping for now.

--b.
