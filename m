From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.6.30-rc deadline scheduler performance regression for iozone
 over NFS
Date: Wed, 13 May 2009 15:45:38 -0400
Message-ID: <1242243938.5407.115.camel@heimdal.trondhjem.org>
References: <x49hc0f79k9.fsf@segfault.boston.devel.redhat.com>
	 <20090508120119.8c93cfd7.akpm@linux-foundation.org>
	 <20090511081415.GL4694@kernel.dk>
	 <x49skjb21b7.fsf@segfault.boston.devel.redhat.com>
	 <20090511165826.GG4694@kernel.dk>
	 <x494ovp4r51.fsf@segfault.boston.devel.redhat.com>
	 <20090512204433.7eb69075.akpm@linux-foundation.org>
	 <x49y6t1rqw0.fsf@segfault.boston.devel.redhat.com>
	 <b4ff356f0905130920v184ab529mb52a4346d4c77c14@mail.gmail.com>
	 <20090513093229.097b47d2.akpm@linux-foundation.org>
	 <20090513182524.GA20778@merit.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Olga Kornievskaia <aglo@citi.umich.edu>,
	Jeff Moyer <jmoyer@redhat.com>,
	Jens Axboe <jens.axboe@oracle.com>,
	linux-kernel@vger.kernel.org, "Rafael J. Wysocki" <rjw@sisk.pl>,
	"J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Jim Rees <rees@umich.edu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761556AbZEMTqq@vger.kernel.org>
In-Reply-To: <20090513182524.GA20778@merit.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-05-13 at 14:25 -0400, Jim Rees wrote:
> Andrew Morton wrote:
> 
>   Jeff's computer got slower.  Can we fix that?
> 
> TCP autotuning can reduce performance by up to about 10% in some cases.
> Jeff found one of these cases.  While the autotuning penalty never exceeds
> 10% as far as I know, I can provide examples of other cases where autotuning
> improves nfsd performance by more than a factor of 100.
> 
> The right thing is to fix autotuning.  If autotuning is considered too
> broken to use, it should be turned off everywhere, not just in nfsd, as it
> hurts/benefits all TCP clients, not just nfs.
> 
> This topic has been discussed before on netdev:
> http://www.spinics.net/lists/netdev/msg68650.html
> http://www.spinics.net/lists/netdev/msg68155.html

Yes, but one consequence of this patch is that the socket send buffer
size sk->sk_sndbuf is now initialised to a smaller value than before.

This again means that the test for xprt->xpt_ops->xpo_has_wspace() in
svc_xprt_enqueue() will fail more often, and so you will be able to
process fewer incoming requests in parallel while you are waiting for
the send window size to build up.

Perhaps the right thing to do here is to allow some limited violation of
the xpo_has_wspace() test while the send window is in the process of
building up?

Cheers
  Trond
