Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:45142 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2389149AbeHGVxa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 7 Aug 2018 17:53:30 -0400
Date: Tue, 7 Aug 2018 15:37:36 -0400
To: linux-nfs@vger.kernel.org
Cc: steved@redhat.com
Subject: nfs4-acl-tools 0.3.4
Message-ID: <20180807193736.GA18187@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs4-acl-tools doesn't get a lot of attention, but it does get a *few*
commits, so it seems a little ridiculous to go 10 years without a
release.  And it was getting annoying for Steve Dickson, who packages
the Fedora version.

So I've tagged 0.3.4 in the git tree at

	git://linux-nfs.org/~bfields/nfs4-acl-tools.git

and posted a tarball at:

	http://linux-nfs.org/~bfields/nfs4-acl-tools/nfs4-acl-tools-0.3.4.tar.gz

Mostly bugfixes; aside from those, one of the only new things you're
likely to notice is recursive nfs4_getfacl support (thanks to Kenneth
Dsouza).

--b.
