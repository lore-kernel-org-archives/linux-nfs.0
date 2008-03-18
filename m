From: "NeilBrown" <neilb@suse.de>
Subject: Re: NFSERR_NOSPC nfs-client bug
Date: Tue, 18 Mar 2008 17:08:31 +1100 (EST)
Message-ID: <32962.192.168.1.70.1205820511.squirrel@neil.brown.name>
References: <200803172021.08327.nfs@share-foo.com>
    <47DF1E5C.9090607@melbourne.sgi.com>
    <200803172050.22223.nfs@share-foo.com>
    <47DF2415.6070802@melbourne.sgi.com>
    <1205809775.22258.9.camel@heimdal.trondhjem.org>
    <47DF3F01.9050504@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "Trond Myklebust" <trond.myklebust@fys.uio.no>, nfs-Uh4cUGhLB8SgSpxsJD1C4w@public.gmane.org,
	linux-nfs@vger.kernel.org
To: "Greg Banks" <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:49333 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751801AbYCRGaQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Mar 2008 02:30:16 -0400
In-Reply-To: <47DF3F01.9050504-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, March 18, 2008 3:03 pm, Greg Banks wrote:
> So that would be
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=7b159fc18d417980f57aef64cab3417ee6af70f8
>
> ?
> Is my reading right, that a solitary transient ENOSPC is still reported
> at close(), but a sequence of two or more ENOSPC is reported in the next
> write() call?

I don't think so.
After an error report is received by the client, the next write/fsync/close
will report the error (even if that write didn't actually have an error).

Also, further writes will be attempted synchronously, so the correct error
is reported, until a write succeeds.  At this point we go back to
async writes.

So a solitary transient ENOSPC will be reported against a subsequent
write.

When a write fails, the page remains DIRTY, so a flush will be attempted
on every subsequent 'sync', including those triggered by a write while
the error flag is set.
So if you keep writing, you will keep getting an error until all dirty
pages have been safely written to the server.

If you give up and close the file, you won't be able to tell just by
looking at the error codes which pages were successfully written and which
aren't.  But it would seem unwise to expect to be able to do that in
any case.

NeilBrown

