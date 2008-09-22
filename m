From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] blocks of zeros (NULLs) in NFS files in kernels >= 2.6.20
Date: Mon, 22 Sep 2008 12:35:22 -0400
Message-ID: <1222101322.7615.6.camel@localhost>
References: <20080905191939.GG22796@merfinllc.com>
	 <56258A29-95D5-4A8C-A097-014B8FEDFB8F@oracle.com>
	 <20080911184951.GB19054@merfinllc.com>  <200809221805.48463.hpj@urpla.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, Aaron Straus <aaron-bYFJunmd+ZV8UrSeD/g0lQ@public.gmane.org>,
	Chuck Lever <chuck.lever@oracle.com>,
	Neil Brown <neilb@suse.de>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Hans-Peter Jansen <hpj-2x7n3sizJbFeoWH0uzbU5w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:41825 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751011AbYIVQf2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Sep 2008 12:35:28 -0400
In-Reply-To: <200809221805.48463.hpj-2x7n3sizJbFeoWH0uzbU5w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2008-09-22 at 18:05 +0200, Hans-Peter Jansen wrote:
> For what is worth, this behavior is visible in bog standard writing/reading 
> files, (log files in my case, via the python logging package). It obviously 
> deviates from local filesystem behavior, and former state of the linux 
> nfs-client. Should we add patches to less, tail, and all other instruments 
> for watching/analysing log files (just to pick the tip of the ice rock) in 
> order to throw away runs of zeros, when reading from nfs mounted files? Or 
> should we ask their maintainers to add locking code for the nfs "read 
> files, which are written at the same time" case, just to work around 
> __some__ of the consequences of this bug? Imagine, how ugly this is going 
> to look! 
> 
> The whole issue is what I call a major regression, thus I strongly ask for a 
> reply from Trond on this matter.
> 
> I even vote for sending a revert request for this hunk to the stable team, 
> where it is applicable, after Trond sorted it out (for 2.6.27?).
> 
> Thanks, Aaron and Chuck for the detailed analysis - it demystified a wired 
> behavior, I observed here. When you're in a process to get real work done 
> in a fixed timeline, such things could make you mad..

Revert _what_ exactly?

Please assume that I've been travelling for the past 5 weeks, and have
only a sketchy idea of what has been going on.
My understanding was that this is a consequence of unordered writes
causing the file to be extended while some other task is reading.
AFAICS, this sort of behaviour has _always_ been possible. I can't see
how reverting anything will fix it.

  Trond

