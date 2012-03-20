Return-Path: linux-nfs-owner@vger.kernel.org
Received: from li9-11.members.linode.com ([67.18.176.11]:56590 "EHLO
	test.thunk.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755479Ab2CTAKg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Mar 2012 20:10:36 -0400
Date: Mon, 19 Mar 2012 20:10:28 -0400
From: "Ted Ts'o" <tytso@mit.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Bernd Schubert <bernd.schubert@fastmail.fm>,
        Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
        "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        yong.fan@whamcloud.com, sandeen@redhat.com, adilger@whamcloud.com
Subject: Re: [PATCH 5 3/4] nfsd_open(): rename 'int access' to 'int
 may_flags' in nfsd_open()
Message-ID: <20120320001028.GA11958@thunk.org>
References: <20120313200117.GA21991@fieldses.org>
 <4F5FA827.8020606@itwm.fraunhofer.de>
 <20120313203446.GB21991@fieldses.org>
 <4F5FB771.9010805@fastmail.fm>
 <20120313212947.GK31995@pad.fieldses.org>
 <4F60AC0D.9020204@itwm.fraunhofer.de>
 <20120314160529.GB31194@fieldses.org>
 <4F63AF2B.5080307@fastmail.fm>
 <20120319025455.GD31682@thunk.org>
 <20120319200041.GA25161@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120319200041.GA25161@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 19, 2012 at 04:00:41PM -0400, J. Bruce Fields wrote:
> Sorry that was more of a hassle than it could have been....  It would be
> nice to try rewriting the cthon tests for xfstests, if that would help
> catch nfs-related bugs sooner.  I don't have the time for now, though.

No problem.  I'd love to look at adapting the connectathon tests for
xfstests as well, but I don't have the time either.

I'll put it on an ext4 todo list; maybe someone who is looking to get
into ext4 programming will take this on as a task.

     	  	      	   	     	   - Ted
