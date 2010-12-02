Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:47150 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757265Ab0LBSg3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Dec 2010 13:36:29 -0500
Date: Thu, 2 Dec 2010 13:36:28 -0500
From: Jim Rees <rees@umich.edu>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: nfsroot mount options
Message-ID: <20101202183628.GA15963@merit.edu>
References: <20101202001821.GA12638@merit.edu>
 <11945697-DC88-4EB3-A9C8-F2A27E0E79BD@oracle.com>
 <20101202170915.GB15530@merit.edu>
 <5B25CFFD-16E3-4BAB-A344-4337F0C79862@oracle.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5B25CFFD-16E3-4BAB-A344-4337F0C79862@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Chuck Lever wrote:

  OK, Ubuntu doesn't use NFSROOT (the kernel's implementation), it actually
  does a real mount in user space.  So all the normal NFS and generic mount
  options ought to work.

I didn't realize that.  I wonder why, especially since it doesn't work.  So
they pack a copy of nfs-utils in their initrd?  And I could maybe use v4 as
the root?

But if that's the case then I'm getting off topic for this list.  Thanks for
your help.
