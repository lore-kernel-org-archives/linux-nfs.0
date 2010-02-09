From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Failure to fallback to nfsd-v3 (?)
Date: Tue, 9 Feb 2010 11:55:47 -0500
Message-ID: <20100209165547.GB29091@fieldses.org>
References: <87pr4h67rf.fsf@devron.myhome.or.jp> <20100207041016.GA16865@fieldses.org> <8763695u96.fsf@devron.myhome.or.jp> <20100208183343.GC10665@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:33434 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755030Ab0BIQzY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Feb 2010 11:55:24 -0500
In-Reply-To: <20100208183343.GC10665@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 08, 2010 at 01:33:43PM -0500, J. Bruce Fields wrote:
> On Sun, Feb 07, 2010 at 05:23:49PM +0900, OGAWA Hirofumi wrote:
> > "J. Bruce Fields" <bfields@fieldses.org> writes:
> > 
> > >> And the following commit seems to change the behavior.
> > >> 
> > >> [nfsd4: fix error return when pseudoroot missing]
> > >> f39bde24b275ddc45df1ed835725b609e178c7a0
> > >> 
> > >> Well, anyway, is this a expected behavior change, or something bug?
> > >
> > > It's expected.  I'd recommend turning off nfsv4 on the server (add "-N4"
> > > to the rpc.nfsd commandline) for now.
> > 
> > This looks like the silent user visible change. So, it would be better
> > to add more comment at least in changelog.
> > 
> > Well, anyway, thanks. (BTW, I assumed rpc.nfsd is typo of rpc.mountd)
> 
> No, the -N4 tells rpc.mountd to turn off NFSv4 support before starting

(Hah!--trying to correct you, I got it wrong myself--I really did mean
rpc.*nfsd*, not rpc.mountd.)

--b.

> the server.
> 
> The problem is that the server is accepting NFSv4 rpc calls even though
> it doesn't actually support v4, so the mount fails a few rpc's later
> with an odd error.
> 
> I changed that error around the same time "mount" on the client was
> modified to start trying v4 support first, and the mount code included a
> workaround for the linux server behavior that only handled exactly the
> old errors.
> 
> --b.
