Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipmail04.adl6.internode.on.net ([150.101.137.141]:51496 "EHLO
	ipmail04.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756409Ab3FFDs4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Jun 2013 23:48:56 -0400
Date: Thu, 6 Jun 2013 13:48:32 +1000
From: Dave Chinner <david@fromorbit.com>
To: Andi Kleen <andi@firstfloor.org>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Waiman Long <waiman.long@hp.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Jeff Layton <jlayton@redhat.com>, Miklos Szeredi <mszeredi@suse.cz>,
        Ian Kent <raven@themaw.net>, Sage Weil <sage@inktank.com>,
        Steve French <sfrench@samba.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Eric Paris <eparis@redhat.com>, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, autofs@vger.kernel.org,
        ceph-devel@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, "Chandramouleeswaran, Aswin" <aswin@hp.com>,
        "Norton, Scott J" <scott.norton@hp.com>
Subject: Re: [PATCH 0/3 v3] dcache: make it more scalable on large system
Message-ID: <20130606034832.GV29338@dastard>
References: <1369273048-60256-1-git-send-email-Waiman.Long@hp.com>
 <20130523094201.GA24543@dastard>
 <519E8B5F.3080905@hp.com>
 <20130527020903.GR29466@dastard>
 <51A624E2.3000301@hp.com>
 <20130529184640.GA3243@fieldses.org>
 <20130529203700.GM6123@two.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130529203700.GM6123@two.firstfloor.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 29, 2013 at 10:37:00PM +0200, Andi Kleen wrote:
> > As Dave said before, is the last path component sufficient?  Or how
> > about an inode number?
> 
> Neither works, the profiler needs to find the file and read it.
> 
> inode searching would be incredible expensive, unless the file system
> provided a "open-by-inode" primitive

That's effectively what fs/fhandle.c gives you.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
