Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([173.255.197.46]:41609 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750888AbbBJScD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Feb 2015 13:32:03 -0500
Date: Tue, 10 Feb 2015 13:32:00 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Nix <nix@esperi.org.uk>
Cc: NeilBrown <neilb@suse.de>, NFS list <linux-nfs@vger.kernel.org>
Subject: Re: what on earth is going on here? paths above mountpoints turn
 into "(unreachable)"
Message-ID: <20150210183200.GB11226@fieldses.org>
References: <87iofju9ht.fsf@spindle.srvr.nix>
 <20150203195333.GQ22301@fieldses.org>
 <87egq6lqdj.fsf@spindle.srvr.nix>
 <87r3u58df2.fsf@spindle.srvr.nix>
 <20150205112641.60340f71@notabene.brown>
 <87zj8l7j3z.fsf@spindle.srvr.nix>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87zj8l7j3z.fsf@spindle.srvr.nix>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 10, 2015 at 05:48:48PM +0000, Nix wrote:
> On 5 Feb 2015, NeilBrown spake thusly:
> 
> > On Wed, 04 Feb 2015 23:28:17 +0000 Nix <nix@esperi.org.uk> wrote:
> >> It doesn't. It still recurs.
> >
> > Is /usr/archive still exported to mutilate with crossmnt?
> > If it is, can you change to not do that (it is quite possible to have
> > different export options for different clients).
> 
> OK. Adjusted.
> 
> > I think that if crossmnt is enabled on the server, then explicitly
> > mounting /usr/archive/series will have the same net effect as not doing so
> > (though I'm not 100% certain).
> >
> > Also, can you try changing
> >    /proc/sys/fs/nfs/nfs_mountpoint_timeout
> >
> > It defaults to 500 (seconds - time for light from Sun to reach Earth).
> > If you make it smaller and the problem gets worse, or make it much bigger
> > and the problem goes away, that would be interesting.
> > If it makes no difference, that also would be interesting.
> 
> Seems to make no difference, which is distinctly surprising. If
> anything, it happens more often at the default value than at either the
> high or low values. It's very erratic: it happened ten times in one day,
> then three days passed and it didn't happen at all... system under
> very similar load the whole time.
> 
> >From other prompts, what I'm seeing now -- but wasn't then, before I
> took the crossmnt out -- is an epidemic of spontaneous unmounting: i.e.,
> /usr/archive/series suddenly vanishes until remounted.
> 
> I might just reboot all systems involved in this mess and hope it goes
> away. I have no *clue* what's going on, I've never seen it before, maybe
> it'll stop if I no longer believe in it.

It might be interesting to see output from

	rpc.debug -m rpc -s cache
	cat /proc/net/rpc/nfsd.export/content
	cat /proc/net/rpc/nfsd.fh/content

especially after the problem manifests.

Also, /usr/archive/series is a separate filesystem from /usr/archive,
right?  (The output of "mount" run on the server might also be useful.)

The reason crossmnt is considered "bad and evil" is that nfsv2 and v3
clients don't necessarily expect mountpoints within exports, and may be
get confused when (for example), they discover to files with the same
inode number that appear to be on the same filesystem.

I'm  not actually sure what the current linux client does--I think it
may be smart enough to use the fsid to avoid at least some of those
problems.  But NFSv4 clients are the only ones that should really be
counted on to get this right.

--b.
