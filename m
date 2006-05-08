From: Neil Brown <neilb@suse.de>
Subject: Re: [NFS] [PATCH,RESEND] make knfsd interact cleanly with HSMs
Date: Mon, 8 May 2006 21:16:34 +1000
Message-ID: <17503.10386.171006.392544@cse.unsw.edu.au>
References: <20060505115254.GA13916@sgi.com>
	<20060508064255.GA8614@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Banks <gnb@sgi.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Linux Filesystem Mailing List <linux-fsdevel@vger.kernel.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: message from Christoph Hellwig on Monday May 8
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Monday May 8, hch@infradead.org wrote:
> NACK.  As long as we have no HSM support in the tree there's no reason to
> add this.  From the kernel's point it's just untested and unused code that
> can break.


Greg: you seemed to suggest that there was already code in XFS that
could make use of this.  If that is so: could you point us to it
please.

Alternately, if this will only be used by future patches, please feel
free to add this patch to that set, and add

  Acked-By: NeilBrown <neilb@suse.de>

to it.

Thanks,
NeilBrown
