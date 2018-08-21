Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:47478 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726852AbeHUUMZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 21 Aug 2018 16:12:25 -0400
Date: Tue, 21 Aug 2018 12:51:30 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: linux-nfs@vger.kernel.org
Cc: steved@redhat.com
Subject: nfs4-acl-tools 0.3.5
Message-ID: <20180821165130.GA14413@fieldses.org>
References: <20180807193736.GA18187@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180807193736.GA18187@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

One more nfs4-acl-tools release.  This removes the GUI, which appears to
have been unused and unmaintained.  I'm happy to revive it from the git
history if someone thinks it's worth taking over.  I also did some minor
tampering with the autotools stuff.

git://linux-nfs.org/~bfields/nfs4-acl-tools.git

http://linux-nfs.org/~bfields/nfs4-acl-tools/nfs4-acl-tools-0.3.5.tar.gz

--b.

On Tue, Aug 07, 2018 at 03:37:36PM -0400, bfields wrote:
> nfs4-acl-tools doesn't get a lot of attention, but it does get a *few*
> commits, so it seems a little ridiculous to go 10 years without a
> release.  And it was getting annoying for Steve Dickson, who packages
> the Fedora version.
> 
> So I've tagged 0.3.4 in the git tree at
> 
> 	git://linux-nfs.org/~bfields/nfs4-acl-tools.git
> 
> and posted a tarball at:
> 
> 	http://linux-nfs.org/~bfields/nfs4-acl-tools/nfs4-acl-tools-0.3.4.tar.gz
> 
> Mostly bugfixes; aside from those, one of the only new things you're
> likely to notice is recursive nfs4_getfacl support (thanks to Kenneth
> Dsouza).
> 
> --b.
