Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:56182 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755623Ab1CPVkr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Mar 2011 17:40:47 -0400
Date: Thu, 17 Mar 2011 08:40:38 +1100
From: NeilBrown <neilb@suse.de>
To: <peter.staubach@emc.com>
Cc: <Trond.Myklebust@netapp.com>, <bjschuma@netapp.com>,
        <linux-nfs@vger.kernel.org>
Subject: Re: Use of READDIRPLUS on large directories
Message-ID: <20110317084038.6d4ea49d@notabene.brown>
In-Reply-To: <5E6794FC7B8FCA41A704019BE3C70E8B068397B4@MX31A.corp.emc.com>
References: <20110316155528.31913c58@notabene.brown>
	<5E6794FC7B8FCA41A704019BE3C70E8B068397B4@MX31A.corp.emc.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 16 Mar 2011 08:30:20 -0400 <peter.staubach@emc.com> wrote:

> Perhaps the use of a heuristic that enables readdirplus only after the application has shown that it is interested in the attributes for each entry in the directory?  Thus, if the application does readdir()/stat()/stat()/stat()/readdir()/... then the NFS client could use readdirplus to fill the caches.  If the application is just reading the directory and looking at the names, then the client could just use readdir.

I think this could work very well.
"ls -l" certainly calls 'stat' on each file after each 'getdents' call.

So we could arrange that the first readdir call on a directory
always uses the 'plus' version, and clears a "seen any getattr calls"
flag on the directory.

nfs_getattr then sets that flag on the parent

subsequent readdir calls only use 'plus' if the flag was set, and
clear the flag again.


There might be odd issues with multiple processes reading and stating
in the same directory, but they probably aren't very serious.

I'm might give this idea a try ... but I still think the original
switch to always use readdirplus is a regression and should be reverted.

Thanks,
NeilBrown

