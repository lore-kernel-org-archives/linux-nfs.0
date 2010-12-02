Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:51935 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752373Ab0LBAS0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Dec 2010 19:18:26 -0500
Received: from localhost (localhost [127.0.0.1])
	by magus.merit.edu (Postfix) with ESMTP id D52D22253C7
	for <linux-nfs@vger.kernel.org>; Wed,  1 Dec 2010 19:18:23 -0500 (EST)
Received: from magus.merit.edu ([127.0.0.1])
	by localhost (magus.merit.edu [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id dQSLea5FMUSX for <linux-nfs@vger.kernel.org>;
	Wed,  1 Dec 2010 19:18:23 -0500 (EST)
Received: from merit.edu (dsl093-001-248.det1.dsl.speakeasy.net [66.93.1.248])
	by magus.merit.edu (Postfix) with ESMTPSA id 571CC22530A
	for <linux-nfs@vger.kernel.org>; Wed,  1 Dec 2010 19:18:23 -0500 (EST)
Date: Wed, 1 Dec 2010 19:18:21 -0500
From: Jim Rees <rees@umich.edu>
To: linux-nfs@vger.kernel.org
Subject: nfsroot mount options
Message-ID: <20101202001821.GA12638@merit.edu>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

If I boot diskless with nfsroot, why is the root file system mounted
readonly?  This makes sense for a file system on disk, since it may have to
be checked before remounting rw, but I don't see why this is needed for
nfsroot.

Also, Documentation/filesystems/nfs/nfsroot.txt says that only nfs options
can be given on the kernel nfsroot option, but I've seen a claim that you
can also put "rw" here.  Are other generic options possible?  How about the
nfs options that aren't listed in the doc?  Should the doc be updated?
