Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54242 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752363Ab1JTT5c (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Oct 2011 15:57:32 -0400
Received: from bfields by fieldses.org with local (Exim 4.72)
	(envelope-from <bfields@fieldses.org>)
	id 1RGyk7-0002qU-OL
	for linux-nfs@vger.kernel.org; Thu, 20 Oct 2011 15:57:31 -0400
Date: Thu, 20 Oct 2011 15:57:31 -0400
To: linux-nfs@vger.kernel.org
Subject: Re: Does NFS4 need st_gen?
Message-ID: <20111020195731.GC9987@fieldses.org>
References: <87ipnlcbg8.fsf@inspiron.ap.columbia.edu>
 <20111019171551.GA32028@fieldses.org>
 <87d3dsdcf4.fsf@inspiron.ap.columbia.edu>
 <20111020120207.GL5444@fieldses.org>
 <877h3za89w.fsf@inspiron.ap.columbia.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <877h3za89w.fsf@inspiron.ap.columbia.edu>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 20, 2011 at 01:21:31PM -0400, Nikolaus Rath wrote:
> I'm working on a FUSE file system that stores file system metadata in an
> SQL database (http://code.google.com/p/s3ql/). Not having to keep track
> of inode generation numbers would keep the code much simpler, because I
> want to delete inode-rows from the SQL table when the last reference to
> the inode is deleted (so I can't keep track of the generation no).

You can use current time, or a counter, or something, as the generation
number.

> Now I'll either have to make inodes unique (and run into trouble after
> 2^32 inodes have been used), or keep with the current scheme of
> randomizing new inodes (which keeps the probability of problems low
> enough but is ugly).

With 2^32 inode numbers plus 2^32 generation numbers it should be
possible to work something out that doesn't require remembering every
old inode.

--b.
