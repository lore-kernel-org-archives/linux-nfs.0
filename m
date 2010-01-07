From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 2/6] VM/NFS: The VM must tell the filesystem when to
 free reclaimable pages
Date: Thu, 07 Jan 2010 00:30:43 -0500
Message-ID: <1262842243.2185.47.camel@localhost>
References: <20100106205110.22547.85345.stgit@localhost.localdomain>
	 <20100106205110.22547.81645.stgit@localhost.localdomain>
	 <20100107022903.GD9475@localhost> <1262839763.2185.25.camel@localhost>
	 <20100107050307.GA19399@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>,
	Steve Rago <sar-a+KepyhlMvJWk0Htik3J/w@public.gmane.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"jens.axboe" <jens.axboe@oracle.com>,
	Peter Staubach <staubach@redhat.com>,
	Arjan van de Ven <arjan@infradead.org>,
	Ingo Molnar <mingo@elte.hu>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14784 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751345Ab0AGFkG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jan 2010 00:40:06 -0500
In-Reply-To: <20100107050307.GA19399@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2010-01-07 at 13:03 +0800, Wu Fengguang wrote:

> "commit" could also be misread as "commit a transaction"?
> Anyway I think adding an "nfs" limits the scope to NFS thus makes code
> reading somehow easier. Just a personal feeling.

How about 'force_commit_unstable' instead? That ties it up to the
unstable writes rather than NFS.

Cheers
  Trond
