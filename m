Return-Path: linux-nfs-owner@vger.kernel.org
Received: from longford.logfs.org ([213.229.74.203]:59340 "EHLO
	longford.logfs.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935568Ab3E3Qkr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 May 2013 12:40:47 -0400
Date: Thu, 30 May 2013 11:11:27 -0400
From: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>
To: Waiman Long <waiman.long@hp.com>
Cc: Andi Kleen <andi@firstfloor.org>, "J. Bruce Fields" <bfields@fieldses.org>,
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
Message-ID: <20130530151127.GA13756@logfs.org>
References: <1369273048-60256-1-git-send-email-Waiman.Long@hp.com>
 <20130523094201.GA24543@dastard>
 <519E8B5F.3080905@hp.com>
 <20130527020903.GR29466@dastard>
 <51A624E2.3000301@hp.com>
 <20130529184640.GA3243@fieldses.org>
 <20130529203700.GM6123@two.firstfloor.org>
 <20130529211917.GB6658@logfs.org>
 <51A774E2.9050307@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <51A774E2.9050307@hp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 30 May 2013 11:48:50 -0400, Waiman Long wrote:
> On 05/29/2013 05:19 PM, Jörn Engel wrote:
> >On Wed, 29 May 2013 22:37:00 +0200, Andi Kleen wrote:
> >>>As Dave said before, is the last path component sufficient?  Or how
> >>>about an inode number?
> >>Neither works, the profiler needs to find the file and read it.
> >Ignoring all the complexity this would cause downstream, you could do
> >the path lookup just once, attach some cookie to it and return the
> >cookie ever-after.  Maybe some combination of i_sb and i_ino would be
> >good enough as a cookie.
> 
> Still, it is just shifting the complexity from the d_path code to
> the perf kernel subsystem as it needs to keep track of what paths
> have been sent up before.

That sounds like a good thing to have.  Every single linux user
depends on the dcache.  Only a relatively small subset cares about
perf.  Having dcache pay the cost for perf's special needs is a
classical externality.

> It also have complications in case the
> tracked files are being deleted or moved around in the filesystem.
> Some kind of notification mechanism has to be implemented in the
> dentry layer to notify the perf subsystem.

Agreed.  The whole approach is based on getting the 99% case right and
occasionally being wrong.  For perf this may be acceptable, not sure.

Jörn

--
Without a major sea change, nothing that is under copyright today will
ever come out from under it and fall into the public domain.
-- Jake Edge
