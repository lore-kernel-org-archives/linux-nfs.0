Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:52078 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753192AbeCQTOR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 17 Mar 2018 15:14:17 -0400
Date: Sat, 17 Mar 2018 19:14:15 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        NeilBrown <neilb@suse.com>
Subject: Re: [PATCH] vfs: remove unnecessary fl_owner_t typedef
Message-ID: <20180317191415.GQ30522@ZenIV.linux.org.uk>
References: <20180317184840.GA32322@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180317184840.GA32322@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Mar 17, 2018 at 02:48:40PM -0400, J. Bruce Fields wrote:
> This is a pretty simple patch that touches a lot of files.  What's the
> procedure for handling patches like this?  I haven't had to do this
> before.

I'm not sure it's a good idea.  We want it opaque - if anything, I would
prefer to have anything mistakenly passing it to a function that takes
a pointer scream like hell at build time.  The current variant doesn't
have such protection, but it can at least be grepped for.  void * can't. 
