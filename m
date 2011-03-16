Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:43863 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750799Ab1CPEzi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Mar 2011 00:55:38 -0400
Date: Wed, 16 Mar 2011 15:55:28 +1100
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Bryan Schumaker <bjschuma@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Use of READDIRPLUS on large directories
Message-ID: <20110316155528.31913c58@notabene.brown>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Hi Trond / Bryan et al.

Now that openSUSE 11.4 is out I have started getting a few reports
of regressions that can be traced to 

commit 0715dc632a271fc0fedf3ef4779fe28ac1e53ef4
Author: Bryan Schumaker <bjschuma@netapp.com>
Date:   Fri Sep 24 18:50:01 2010 -0400

    NFS: remove readdir plus limit
    
    We will now use readdir plus even on directories that are very large.
    
    Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>


This particularly affects users with their home directory over
NFS, and with largish maildir mail folders.

Where it used to take a smallish number of seconds for (e.g.)
xbiff to start up and read through the various directories, it now
takes multiple minutes.

I can confirm that the slow down is due to readdirplus by mounting the
filesystem with nordirplus.


While I can understand that there are sometime benefits in using
readdirplus for very large directories, there are also obviously real
costs.  So I think we have to see this patch as a regression that should
be reverted.


It would quite possibly make sense to create a tunable (mount option or
sysctl I guess) to set the max size for directories to use readdirplus,
but I think it really should be an opt-in situation.

[[ It would also be really nice if the change-log for such a significant
change contained a little more justification.... :-(   ]]

Thoughts?

Thanks,
NeilBrown
