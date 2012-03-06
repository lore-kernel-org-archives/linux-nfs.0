Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:60003 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752598Ab2CFP2s (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Mar 2012 10:28:48 -0500
Date: Tue, 6 Mar 2012 10:28:43 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: "Ted Ts'o" <tytso@mit.edu>
Cc: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
        linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, yong.fan@whamcloud.com,
        sandeen@redhat.com, adilger@whamcloud.com
Subject: Re: [PATCH 5 3/4] nfsd_open(): rename 'int access' to 'int
 may_flags' in nfsd_open()
Message-ID: <20120306152842.GA8339@pad.fieldses.org>
References: <20120109132158.2616029.30467.stgit@localhost.localdomain>
 <20120109132153.2616029.26302.stgit@localhost.localdomain>
 <20120306000837.GA17164@thunk.org>
 <20120306020819.GH31388@pad.fieldses.org>
 <20120306151816.GB32282@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120306151816.GB32282@thunk.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 06, 2012 at 10:18:16AM -0500, Ted Ts'o wrote:
> On Mon, Mar 05, 2012 at 09:08:19PM -0500, J. Bruce Fields wrote:
> > Yes, that would be fine.
> > 
> > (There may well be some conflict: simplest might be if you can get that
> > pushed out to a stable public branch somewhere, hopefully before the
> > merge window opens, and that'll give me a chance to pull it and handle
> > any merge conflicts.
> 
> Are the commits you're worried about on the NFS side already in
> linux-next?

No (though there might be some other conflicts there I haven't thought
of).

> If so, I'll do a quick test merge and see if there are
> any conflicts.  If so, I'll segregate out these patches into a
> separate pre-merge branch --- and then if you like you could pull them
> into your branch and we can deal with it that way.

That sounds like a good way to do it regardless?

--b.
