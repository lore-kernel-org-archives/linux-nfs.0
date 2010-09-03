Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:35309 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754363Ab0ICP6x (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 Sep 2010 11:58:53 -0400
Received: from bfields by fieldses.org with local (Exim 4.71)
	(envelope-from <bfields@fieldses.org>)
	id 1OrYeh-0001th-3R
	for linux-nfs@vger.kernel.org; Fri, 03 Sep 2010 11:58:19 -0400
Date: Fri, 3 Sep 2010 11:58:19 -0400
To: linux-nfs@vger.kernel.org
Subject: 4.1 testing
Message-ID: <20100903155818.GF2245@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I added the pynfs41 tests to my regular regression tests, and have a set
of tests that currently pass.  The version of the tests I'm running
include some fixes to the tests necessary to get them working correctly
against the server:

	git://linux-nfs.org/~bfields/pynfs41.git

My test scripts are at

	git://linux-nfs.org/~bfields/testd.git

The pynfs41 commandline is in bin/do-pynfs41, and the set of tests I'm
currently omitting is in data/pynfs41-skip.  The latter file is roughly
ordered with the tests I think need to be looked at first at the top.

By the way, I also have a pynfs 4.0 repository:

	git://linux-nfs.org/~bfields/pynfs.git

and there's also a pynfs-skip file with the tests I'm skipping in the
4.0 case.  (Most are not currently a high priority to fix.)

Thanks to CITI interns Michael Groshans and to Muneet Parhar for the
pynfs 4.1 and 4.0 work.

--b.
