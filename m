Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:34702 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755497Ab2IFO26 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Sep 2012 10:28:58 -0400
Subject: Re: [RFC PATCH 01/13] gfs2: Get rid of I_MUTEX_QUOTA usage
From: Steven Whitehouse <swhiteho@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "J. Bruce Fields" <bfields@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Jan Kara <jack@suse.cz>
In-Reply-To: <20120905205920.GA10724@fieldses.org>
References: <1346878524-10585-1-git-send-email-bfields@redhat.com>
	 <1346878524-10585-2-git-send-email-bfields@redhat.com>
	 <20120905205920.GA10724@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 06 Sep 2012 15:27:46 +0100
Message-ID: <1346941666.2728.17.camel@menhir>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

On Wed, 2012-09-05 at 16:59 -0400, J. Bruce Fields wrote:
> On Wed, Sep 05, 2012 at 04:55:11PM -0400, J. Bruce Fields wrote:
> > From: Jan Kara <jack@suse.cz>
> > 
> > GFS2 uses i_mutex on its system quota inode to synchronize writes to
> > quota file. Since this is an internal inode to GFS2 (not part of directory
> > hiearchy or visible by user) we are safe to define locking rules for it. So
> > let's just get it its own locking class to make it clear.
> 
> By the way, Steve, is there any reason you haven't taken this through
> the gfs2 tree?
> 
> --b.
> 
I don't remember now, but I've pushed it into my tree for the next merge
window,

Steve.




