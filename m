Return-Path: linux-nfs-owner@vger.kernel.org
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:24884 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756144Ab3E3PtH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 May 2013 11:49:07 -0400
Message-ID: <51A774E2.9050307@hp.com>
Date: Thu, 30 May 2013 11:48:50 -0400
From: Waiman Long <waiman.long@hp.com>
MIME-Version: 1.0
To: =?UTF-8?B?SsO2cm4gRW5nZWw=?= <joern@logfs.org>
CC: Andi Kleen <andi@firstfloor.org>, "J. Bruce Fields" <bfields@fieldses.org>,
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
References: <1369273048-60256-1-git-send-email-Waiman.Long@hp.com> <20130523094201.GA24543@dastard> <519E8B5F.3080905@hp.com> <20130527020903.GR29466@dastard> <51A624E2.3000301@hp.com> <20130529184640.GA3243@fieldses.org> <20130529203700.GM6123@two.firstfloor.org> <20130529211917.GB6658@logfs.org>
In-Reply-To: <20130529211917.GB6658@logfs.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/29/2013 05:19 PM, Jörn Engel wrote:
> On Wed, 29 May 2013 22:37:00 +0200, Andi Kleen wrote:
>>> As Dave said before, is the last path component sufficient?  Or how
>>> about an inode number?
>> Neither works, the profiler needs to find the file and read it.
> Ignoring all the complexity this would cause downstream, you could do
> the path lookup just once, attach some cookie to it and return the
> cookie ever-after.  Maybe some combination of i_sb and i_ino would be
> good enough as a cookie.

Still, it is just shifting the complexity from the d_path code to the 
perf kernel subsystem as it needs to keep track of what paths have been 
sent up before. It also have complications in case the tracked files are 
being deleted or moved around in the filesystem. Some kind of 
notification mechanism has to be implemented in the dentry layer to 
notify the perf subsystem.

Regards,
Longman
