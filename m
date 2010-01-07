From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/6] VM/NFS: The VM must tell the filesystem when to
	free reclaimable pages
Date: Thu, 7 Jan 2010 22:37:35 +0800
Message-ID: <20100107143735.GA20300@localhost>
References: <20100106205110.22547.85345.stgit@localhost.localdomain> <20100106205110.22547.81645.stgit@localhost.localdomain> <20100107022903.GD9475@localhost> <1262839763.2185.25.camel@localhost> <20100107050307.GA19399@localhost> <1262842243.2185.47.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>,
	Steve Rago <sar-a+KepyhlMvJWk0Htik3J/w@public.gmane.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"jens.axboe" <jens.axboe@oracle.com>,
	Peter Staubach <staubach@redhat.com>,
	Arjan van de Ven <arjan@infradead.org>,
	Ingo Molnar <mingo@elte.hu>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:1504 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752449Ab0AGOh7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Jan 2010 09:37:59 -0500
In-Reply-To: <1262842243.2185.47.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 07, 2010 at 01:30:43PM +0800, Trond Myklebust wrote:
> On Thu, 2010-01-07 at 13:03 +0800, Wu Fengguang wrote:
> 
> > "commit" could also be misread as "commit a transaction"?
> > Anyway I think adding an "nfs" limits the scope to NFS thus makes code
> > reading somehow easier. Just a personal feeling.
> 
> How about 'force_commit_unstable' instead? That ties it up to the
> unstable writes rather than NFS.

That would be good, thanks!

Fengguang
