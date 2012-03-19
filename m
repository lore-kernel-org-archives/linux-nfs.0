Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57135 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030574Ab2CSUAq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Mar 2012 16:00:46 -0400
Date: Mon, 19 Mar 2012 16:00:41 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Ted Ts'o" <tytso@mit.edu>
Cc: Bernd Schubert <bernd.schubert@fastmail.fm>,
        Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
        "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        yong.fan@whamcloud.com, sandeen@redhat.com, adilger@whamcloud.com
Subject: Re: [PATCH 5 3/4] nfsd_open(): rename 'int access' to 'int
 may_flags' in nfsd_open()
Message-ID: <20120319200041.GA25161@fieldses.org>
References: <20120312222250.GD8991@fieldses.org>
 <20120313200117.GA21991@fieldses.org>
 <4F5FA827.8020606@itwm.fraunhofer.de>
 <20120313203446.GB21991@fieldses.org>
 <4F5FB771.9010805@fastmail.fm>
 <20120313212947.GK31995@pad.fieldses.org>
 <4F60AC0D.9020204@itwm.fraunhofer.de>
 <20120314160529.GB31194@fieldses.org>
 <4F63AF2B.5080307@fastmail.fm>
 <20120319025455.GD31682@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120319025455.GD31682@thunk.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Mar 18, 2012 at 10:54:55PM -0400, Ted Ts'o wrote:
> On Fri, Mar 16, 2012 at 10:22:51PM +0100, Bernd Schubert wrote:
> > On 03/14/2012 05:05 PM, J. Bruce Fields wrote:
> > >On Wed, Mar 14, 2012 at 03:32:45PM +0100, Bernd Schubert wrote:
> > >>shall I sent an updated version of the previous ext4 patch
> > >>or is this patch sufficient?
> > >
> > >Up to Ted.
> > >
> > >Ted, I haven't published my merge of your branch, so at least for my
> > >purposes I don't care whether you fold this in or pop another patch on
> > >top.
> > 
> > Ted, could you please tell me how to proceed?
> 
> I've merged it in.
> 
> Bruce, I have an updated tag and branch at:
> 
>    git://git.kernel.org/pub/scm/linux/kernel/git/tytso/ext4.git nfs-ext4-premerge
> 
> Can you give it a try and pull it in if it passes your tests?

Looks good.

(Merged and pushed out to my git://linux-nfs.org/~bfields/linux.git.)

Sorry that was more of a hassle than it could have been....  It would be
nice to try rewriting the cthon tests for xfstests, if that would help
catch nfs-related bugs sooner.  I don't have the time for now, though.

Merging a topic branch like this looks like it should work fine, anyway.

Thanks!

--b.

commit 62b9510cb373d5722fdaba71d961d8f695acfcd5
Merge: 8546ee5 06effdb
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Mon Mar 19 12:34:39 2012 -0400

    nfsd: merge cookie collision fixes from ext4 tree
    
    These changes fix readdir loops on ext4 filesystems with dir_index
    turned on.  I'm pulling them from Ted's tree as I'd like to give them
    some extra nfsd testing, and expect to be applying (potentially
    conflicting) patches to the same code before the next merge window.
    
    From the nfs-ext4-premerge branch of
    
    	git://git.kernel.org/pub/scm/linux/kernel/git/tytso/ext4
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

