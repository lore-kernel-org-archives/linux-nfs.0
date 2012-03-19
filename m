Return-Path: linux-nfs-owner@vger.kernel.org
Received: from li9-11.members.linode.com ([67.18.176.11]:40700 "EHLO
	test.thunk.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750882Ab2CSCy6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 18 Mar 2012 22:54:58 -0400
Date: Sun, 18 Mar 2012 22:54:55 -0400
From: "Ted Ts'o" <tytso@mit.edu>
To: Bernd Schubert <bernd.schubert@fastmail.fm>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
        "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        yong.fan@whamcloud.com, sandeen@redhat.com, adilger@whamcloud.com
Subject: Re: [PATCH 5 3/4] nfsd_open(): rename 'int access' to 'int
 may_flags' in nfsd_open()
Message-ID: <20120319025455.GD31682@thunk.org>
References: <20120312154921.GB17153@pad.fieldses.org>
 <20120312222250.GD8991@fieldses.org>
 <20120313200117.GA21991@fieldses.org>
 <4F5FA827.8020606@itwm.fraunhofer.de>
 <20120313203446.GB21991@fieldses.org>
 <4F5FB771.9010805@fastmail.fm>
 <20120313212947.GK31995@pad.fieldses.org>
 <4F60AC0D.9020204@itwm.fraunhofer.de>
 <20120314160529.GB31194@fieldses.org>
 <4F63AF2B.5080307@fastmail.fm>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F63AF2B.5080307@fastmail.fm>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 16, 2012 at 10:22:51PM +0100, Bernd Schubert wrote:
> On 03/14/2012 05:05 PM, J. Bruce Fields wrote:
> >On Wed, Mar 14, 2012 at 03:32:45PM +0100, Bernd Schubert wrote:
> >>shall I sent an updated version of the previous ext4 patch
> >>or is this patch sufficient?
> >
> >Up to Ted.
> >
> >Ted, I haven't published my merge of your branch, so at least for my
> >purposes I don't care whether you fold this in or pop another patch on
> >top.
> 
> Ted, could you please tell me how to proceed?

I've merged it in.

Bruce, I have an updated tag and branch at:

   git://git.kernel.org/pub/scm/linux/kernel/git/tytso/ext4.git nfs-ext4-premerge

Can you give it a try and pull it in if it passes your tests?

    	     	      	       	     	- Ted
