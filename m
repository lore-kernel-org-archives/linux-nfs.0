From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [NFS] [PATCH,RESEND] make knfsd interact cleanly with HSMs
Date: Mon, 8 May 2006 18:55:15 +0100
Message-ID: <20060508175515.GA9662@infradead.org>
References: <20060505115254.GA13916@sgi.com> <20060508064255.GA8614@infradead.org> <17503.10386.171006.392544@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>, Greg Banks <gnb@sgi.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Linux Filesystem Mailing List <linux-fsdevel@vger.kernel.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17503.10386.171006.392544@cse.unsw.edu.au>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Mon, May 08, 2006 at 09:16:34PM +1000, Neil Brown wrote:
> On Monday May 8, hch@infradead.org wrote:
> > NACK.  As long as we have no HSM support in the tree there's no reason to
> > add this.  From the kernel's point it's just untested and unused code that
> > can break.
> 
> 
> Greg: you seemed to suggest that there was already code in XFS that
> could make use of this.  If that is so: could you point us to it
> please.

It's used by SGI's out of tree dmapi implementation.  Because dmapi is such
an utterly braindead standard I don't expect anyone to submit a kernel-based
implementation for inclusion, although support for a big enough subset of
that standard could be archived by proper kernel <-> userspace cooperation.

