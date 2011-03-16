Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mexforward.lss.emc.com ([128.222.32.20]:51297 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751957Ab1CPMap convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Mar 2011 08:30:45 -0400
From: <peter.staubach@emc.com>
To: <neilb@suse.de>, <Trond.Myklebust@netapp.com>, <bjschuma@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Date: Wed, 16 Mar 2011 08:30:20 -0400
Subject: RE: Use of READDIRPLUS on large directories
Message-ID: <5E6794FC7B8FCA41A704019BE3C70E8B068397B4@MX31A.corp.emc.com>
References: <20110316155528.31913c58@notabene.brown>
In-Reply-To: <20110316155528.31913c58@notabene.brown>
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Perhaps the use of a heuristic that enables readdirplus only after the application has shown that it is interested in the attributes for each entry in the directory?  Thus, if the application does readdir()/stat()/stat()/stat()/readdir()/... then the NFS client could use readdirplus to fill the caches.  If the application is just reading the directory and looking at the names, then the client could just use readdir.

		ps


-----Original Message-----
From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of NeilBrown
Sent: Wednesday, March 16, 2011 12:55 AM
To: Trond Myklebust; Bryan Schumaker
Cc: linux-nfs@vger.kernel.org
Subject: Use of READDIRPLUS on large directories


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
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

