From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: nfsservctl(2)
Date: Mon, 8 Aug 2011 12:22:32 -0400
Message-ID: <20110808162232.GC904@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-man-AT-vger.kernel.org@fieldses.org,
	NeilBrown <neilb@suse.de>, linux-nfs@vger.kernel.org
To: mtk.manpages-AT-gmail.com@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:51729 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752347Ab1HHQWd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Aug 2011 12:22:33 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The nfsservctl system call has long been superceded by a better
interface, and is finally getting removed in the 3.1 kernel.

I'm not sure what to do with the man page--remove it, or add a note
saying it's gone from recent kernels?  Do you have something you
generally do in such cases?

It's been replaced by a set of files in the nfsd filesystem, which is
documented in nfsd(7).  That man page looks sufficiently up-to-date to
cover the functionality previous provided by nfsservctl.  (Though I only
skimmed it quickly.  It might be worth a more careful review some day.)

--b.
