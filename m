From: "Hans-Peter Jansen" <hpj-2x7n3sizJbFeoWH0uzbU5w@public.gmane.org>
Subject: Re: [NFS] blocks of zeros (NULLs) in NFS files in kernels >= 2.6.20
Date: Mon, 22 Sep 2008 18:05:47 +0200
Message-ID: <200809221805.48463.hpj@urpla.net>
References: <20080905191939.GG22796@merfinllc.com> <56258A29-95D5-4A8C-A097-014B8FEDFB8F@oracle.com> <20080911184951.GB19054@merfinllc.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Cc: Aaron Straus <aaron-bYFJunmd+ZV8UrSeD/g0lQ@public.gmane.org>,
	Chuck Lever <chuck.lever@oracle.com>,
	Neil Brown <neilb@suse.de>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: linux-kernel@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:52212 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752829AbYIVQGA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Sep 2008 12:06:00 -0400
In-Reply-To: <20080911184951.GB19054-bYFJunmd+ZV8UrSeD/g0lQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Aaron, hi NFS hackers,

Am Donnerstag, 11. September 2008 schrieb Aaron Straus:
> Hi,
>
> On Sep 11 01:48 PM, Chuck Lever wrote:
> > Were you able to modify your writer to do real fsync system calls?  If
> > so, did it help?  That would be a useful data point.
>
> Yes/Yes.  Please see the attached tarball sync-test.tar.bz2.
>
> Inside you'll find the modified writer:  writer_sync.py
>
> That will call fsync on the file descriptor after each write.
>
> Also I added the strace and wireshark data for the sync and nosync
> cases.
>
> Note these are all tested with latest linus git:
>
>   d1c6d2e547148c5aa0c0a4ff6aac82f7c6da1d8b
>
> > Practically speaking this is often not enough for typical
> > applications, so NFS client implementations go to further (non-
> > standard) efforts to behave like a local file system.  This is simply
> > a question of whether we can address this while not creating
> > performance or correctness issues for other common use cases.
>
> Yep, I agree.  I'm not saying what we do now is "wrong" per the RFC
> (writing the file out of order).  It's just different from what we've
> done in the past (and somewhat unexpected).
>
> I'm still hoping there is a simple fix... but maybe not... :(

For what is worth, this behavior is visible in bog standard writing/reading 
files, (log files in my case, via the python logging package). It obviously 
deviates from local filesystem behavior, and former state of the linux 
nfs-client. Should we add patches to less, tail, and all other instruments 
for watching/analysing log files (just to pick the tip of the ice rock) in 
order to throw away runs of zeros, when reading from nfs mounted files? Or 
should we ask their maintainers to add locking code for the nfs "read 
files, which are written at the same time" case, just to work around 
__some__ of the consequences of this bug? Imagine, how ugly this is going 
to look! 

The whole issue is what I call a major regression, thus I strongly ask for a 
reply from Trond on this matter.

I even vote for sending a revert request for this hunk to the stable team, 
where it is applicable, after Trond sorted it out (for 2.6.27?).

Thanks, Aaron and Chuck for the detailed analysis - it demystified a wired 
behavior, I observed here. When you're in a process to get real work done 
in a fixed timeline, such things could make you mad..

Cheers,
Pete
