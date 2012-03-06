Return-Path: linux-nfs-owner@vger.kernel.org
Received: from li9-11.members.linode.com ([67.18.176.11]:56688 "EHLO
	test.thunk.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030453Ab2CFPSS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Mar 2012 10:18:18 -0500
Date: Tue, 6 Mar 2012 10:18:16 -0500
From: "Ted Ts'o" <tytso@mit.edu>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
        linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, yong.fan@whamcloud.com,
        sandeen@redhat.com, adilger@whamcloud.com
Subject: Re: [PATCH 5 3/4] nfsd_open(): rename 'int access' to 'int
 may_flags' in nfsd_open()
Message-ID: <20120306151816.GB32282@thunk.org>
References: <20120109132158.2616029.30467.stgit@localhost.localdomain>
 <20120109132153.2616029.26302.stgit@localhost.localdomain>
 <20120306000837.GA17164@thunk.org>
 <20120306020819.GH31388@pad.fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120306020819.GH31388@pad.fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 05, 2012 at 09:08:19PM -0500, J. Bruce Fields wrote:
> Yes, that would be fine.
> 
> (There may well be some conflict: simplest might be if you can get that
> pushed out to a stable public branch somewhere, hopefully before the
> merge window opens, and that'll give me a chance to pull it and handle
> any merge conflicts.

Are the commits you're worried about on the NFS side already in
linux-next?  If so, I'll do a quick test merge and see if there are
any conflicts.  If so, I'll segregate out these patches into a
separate pre-merge branch --- and then if you like you could pull them
into your branch and we can deal with it that way.

     	  	     	    	      	 - Ted
