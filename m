From: Neil Brown <neilb@suse.de>
Subject: Re: Invisible files and input/output errors
Date: Tue, 4 Dec 2007 11:23:52 +1100
Message-ID: <18260.40472.276614.78174@notabene.brown>
References: <200712040037.36598.bartoschek@or.uni-bonn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Christoph Bartoschek <bartoschek-eefaeeawk+jFLWzOrOlZPg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:37002 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750896AbXLDAX6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Dec 2007 19:23:58 -0500
In-Reply-To: message from Christoph Bartoschek on Tuesday December 4
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tuesday December 4, bartoschek-eefaeeawk+jFLWzOrOlZPg@public.gmane.org wrote:
> Hi,
> 
> we use a DFS-NFS-Gateway on AIX 5.1 as our NFS-Server. This works fine most of 
> the time but for four months we have strange problems. There are basically 
> two issues:
> 
> 1. Using "ls" in specific directories after certain idle time gives us 
> an "Input/Output Error" without any results.
> 
> 2. In some directories some entries are not shown. For example there is a 
> directory with the subdirectory ak_fcp in it. "ls" does not show this 
> directory. But it is possible to do "cd ak_fcp" and then normally work with 
> it.  It is also possible to access files in the directory while being in the 
> parent directory: " less ak_fcp/logfile"  works.
> 
> Does anybody know how to get rid of the problems? The problems occur on 
> several different linux versions.

Sounds a lot like directory cookie problems.

Can you get a network trace of the NFS packets.
Something like

    tcpdump -s 0 -w /tmp/trace host NAME-OF-SERVER

then cause the failure while that is running.
Either compress and attach the result to an Email, or if it is too
big, stick it on a website somewhere.

NeilBrown
