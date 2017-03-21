Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:41972 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932757AbdCUPuC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 21 Mar 2017 11:50:02 -0400
Date: Tue, 21 Mar 2017 11:50:00 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Olga Kornievskaia <kolga@netapp.com>
Cc: Christoph Hellwig <hch@lst.de>, linux-fsdevel@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        ng-linux-team <ng-linux-team@netapp.com>
Subject: Re: [PATCH v1 2/3] VFS permit cross device vfs_copy_file_range
Message-ID: <20170321155000.GB15402@fieldses.org>
References: <20170302160211.30451-1-kolga@netapp.com>
 <20170302160211.30451-3-kolga@netapp.com>
 <20170302160714.GA4760@lst.de>
 <0ADCDD29-61BA-46CA-902C-06A6F7D06450@netapp.com>
 <20170315180913.GB18135@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170315180913.GB18135@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 15, 2017 at 02:09:13PM -0400, J. Bruce Fields wrote:
> On Thu, Mar 02, 2017 at 11:38:03AM -0500, Olga Kornievskaia wrote:
> > > On Mar 2, 2017, at 11:07 AM, Christoph Hellwig <hch@lst.de> wrote:
> > > NAK, we really should not do operations between different
> > > superblocks.
> > 
> > Can you provide some reasoning as to why? What would it break? The
> > reasoning for including one is to allow for a file system to achieve
> > better performance which seems like a feature that would be of great
> > benefit. --
> 
> Yes, this has come up a few times.  What's going on?:
> 
> 	- There was an explanation, and I missed it.
> 	- The explanation is complicated and Christoph hasn't had time
> 	  to write it up.
> 	- Christoph has a strong suspicion there are issues without
> 	  being sure exactly where they are.
> 	- Something else?

As far as I can tell from talking at LSF:

	- file system operations crossing superblocks is unusual.  No
	  specific known issue.  Also not sure I understand why splice
	  isn't precedent.
	- implementation (with server acting as a client, long-running
	  process, etc.) will be complicated and ugly.  Sure, I guess
	  we'll see how complicated and weigh that against any
	  advantages.  (Though I'm curious about case e.g. of btrfs
	  clone--can't it easily clone across filesystem boundaries in
	  some cases when they share storage?)

Anyway.  I'll read the patches.  Probably not this week.

--b.
