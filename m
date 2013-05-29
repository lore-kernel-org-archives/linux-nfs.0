Return-Path: linux-nfs-owner@vger.kernel.org
Received: from one.firstfloor.org ([193.170.194.197]:37443 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966862Ab3E2VBD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 May 2013 17:01:03 -0400
Date: Wed, 29 May 2013 23:01:01 +0200
From: Andi Kleen <andi@firstfloor.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Andi Kleen <andi@firstfloor.org>, Waiman Long <waiman.long@hp.com>,
        Dave Chinner <david@fromorbit.com>,
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
Message-ID: <20130529210101.GN6123@two.firstfloor.org>
References: <1369273048-60256-1-git-send-email-Waiman.Long@hp.com>
 <20130523094201.GA24543@dastard>
 <519E8B5F.3080905@hp.com>
 <20130527020903.GR29466@dastard>
 <51A624E2.3000301@hp.com>
 <20130529184640.GA3243@fieldses.org>
 <20130529203700.GM6123@two.firstfloor.org>
 <20130529204323.GC3243@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130529204323.GC3243@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 29, 2013 at 04:43:23PM -0400, J. Bruce Fields wrote:
> On Wed, May 29, 2013 at 10:37:00PM +0200, Andi Kleen wrote:
> > > As Dave said before, is the last path component sufficient?  Or how
> > > about an inode number?
> > 
> > Neither works, the profiler needs to find the file and read it.
> > 
> > inode searching would be incredible expensive,
> 
> How fast does it need to be?  Actually analyzing the profile is
> something you only do once after everything's over, right?

"perf top" does it live.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
