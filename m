From: Simon Kirby <sim@hostway.ca>
Subject: Re: 2.6.28.9: EXT3/NFS inodes corruption
Date: Thu, 20 Aug 2009 17:00:35 -0700
Message-ID: <20090821000035.GB13221@hostway.ca>
References: <20090727154253.GB8332@duck.suse.cz> <20090728112715.GA8442@gradator.net> <20090728135226.GA21682@duck.suse.cz> <20090728164142.GA13662@gradator.net> <20090803222901.GB23162@duck.suse.cz> <20090804111505.GA6433@gradator.net> <20090804225619.GB11097@duck.suse.cz> <20090806131555.GA23359@gradator.net> <20090812223453.GC10729@duck.suse.cz> <20090820171952.GA15133@gradator.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org,
	linux-ext4@vger.kernel.org, linux-nfs@vger.kernel.org,
	Al Viro <viro@zeniv.linux.org.uk>
To: Sylvain Rochet <gradator-XWGZPxRNpGHk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from newpeace.netnation.com ([204.174.223.7]:40027 "EHLO
	peace.netnation.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754462AbZHUAAn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Aug 2009 20:00:43 -0400
In-Reply-To: <20090820171952.GA15133-XWGZPxRNpGHk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 20, 2009 at 07:19:53PM +0200, Sylvain Rochet wrote:

> So, everything is fine, but the problem happened only one time on this 
> server, so we cannot conclude anything after a few weeks. However, 
> I now have physical access back, so we will switch back to the former 
> server where the problem happened quite frequently, then we will see!

Not to derail the thread, but you were definitely seeing the same issues
with stock 2.6.30.4, right?  We had all sorts of corruption happening for
files served via NFS with 2.6.28 and 2.6.29, but everything was magically
fixed on 2.6.30 (though we needed a lot of fscking).  I never did track
down what change fixed it, since it took a while to reproduce.

Hmm.  I just noticed what seems to be a new occurrence of "deleted inode
referenced" on a box with 2.6.30.  We saw many when we first upgraded to
2.6.30 due to the corruption caused by 2.6.29, but those all occurred
within a day or so and were fsck'd.  I would have thought the backup
sweeps would have tripped over that inode way before now...

Just wondering if you can confirm that the errors you saw with 2.6.30.4
were not leftover from older kernels.

Cheers,

Simon-
