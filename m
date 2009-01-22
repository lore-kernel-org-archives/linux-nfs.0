From: David Teigland <teigland@redhat.com>
Subject: Re: [Cluster-devel] Re: [PATCH 1/2] dlm: initialize file_lock struct in GETLK before copying conflicting lock
Date: Thu, 22 Jan 2009 13:03:45 -0600
Message-ID: <20090122190345.GB23796@redhat.com>
References: <1232555691-29859-1-git-send-email-jlayton@redhat.com> <1232555691-29859-2-git-send-email-jlayton@redhat.com> <20090121234239.GM4295@fieldses.org> <20090122180543.GA23796@redhat.com> <20090122133733.5d692a09@barsoom.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	linux-fsdevel@vger.kernel.org, cluster-devel@redhat.com,
	linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	lkml@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:36594 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753164AbZAVTER (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Jan 2009 14:04:17 -0500
In-Reply-To: <20090122133733.5d692a09-xSBYVWDuneFaJnirhKH9O4GKTjYczspe@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 22, 2009 at 01:37:33PM -0500, Jeff Layton wrote:
> > using locks_init_lock() plus the existing assignments.  But, I think the
> > best solution may be for dlm_posix_get() to set up a new lightweight
> > file_lock with the values we need, and then call __locks_copy_lock() with
> > it, just like posix_test_lock().
> 
> Why would we want to make another lock here? Is that just to make sure that
> if new fields are added later that we deal with them appropriately?

Just so we could use the __locks_copy_lock() function to make the assignments
for us.  Setting up the fake file_lock just for that purpose might not be
worth it, though, so I'm happy to stick with the current patch.

Dave

