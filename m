From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] 2.4.20 Direct IO patch for NFS. (Note: a trivial API change...)
Date: Mon, 30 Sep 2002 19:42:27 +0100
Sender: linux-fsdevel-owner@vger.kernel.org
Message-ID: <20020930194227.A22095@infradead.org>
References: <15768.39196.468797.249573@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>,
	Chuck Lever <cel@netapp.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Linux FSdevel <linux-fsdevel@vger.kernel.org>,
	NFS maillist <nfs@lists.sourceforge.net>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <15768.39196.468797.249573@charged.uio.no>; from trond.myklebust@fys.uio.no on Mon, Sep 30, 2002 at 08:34:04PM +0200
List-ID: <nfs.lists.sourceforge.net>

On Mon, Sep 30, 2002 at 08:34:04PM +0200, Trond Myklebust wrote:
> 
> Hi Marcelo,
> 
>   The following patch implements direct I/O for NFS as a compilation option.
> It does not in any way touch the standard NFS read/write code, however it
> does change the interface for generic direct I/O: Instead of taking a
> 'struct inode' argument, we need to take the full 'struct file' in order
> to be able to pass the RPC credential information down to the NFS layer.

I don't think changing the filesystem entry points during 2.4 is an option.

