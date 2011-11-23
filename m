Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:48107 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751005Ab1KWS1y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Nov 2011 13:27:54 -0500
Date: Wed, 23 Nov 2011 13:27:53 -0500
To: bjschuma@netapp.com
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [RFC 0/4] NFS: Modularize NFS v3
Message-ID: <20111123182752.GA32713@fieldses.org>
References: <1322002684-20436-1-git-send-email-bjschuma@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1322002684-20436-1-git-send-email-bjschuma@netapp.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 22, 2011 at 05:57:59PM -0500, bjschuma@netapp.com wrote:
> From: Bryan Schumaker <bjschuma@netapp.com>
> 
> This set of patches removes NFS v3 from the main NFS kernel module and creates
> a new module containing the proc, xdr, and acl code.  This will give us a
> single directory to put NFS v3 specific code so it doesn't need to be mixed in
> with the generic client stuff.
> 
> I'm sure this could still use a lot of work, but I figured I would wait to see
> what everybody thinks first.  I imagine that once we get an "nfs submodule"
> system working it'll be easier to convert v2 and v4 (and possibly v4.1?) to
> modules.
> 
> I split the second patch into two to make it easier to see what my changes were
> to get everything to compile.  Hopefully this will save some pain in having to
> look through 7000+ line patch that resulted from my `mv nfs3*.c nfs3/`
> command.  I can combine everything in a future version of the patch.
> 
> Thoughts?

Is this purely cleanup, or is there some practical reason why people
need to be able to unload v3 at runtime?

--b.
