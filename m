From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] 2.4.20 Direct IO patch for NFS. (Note: a trivial API
	change...)
Date: 30 Sep 2002 20:18:20 +0100
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <1033413501.17501.36.camel@irongate.swansea.linux.org.uk>
References: <15768.39196.468797.249573@charged.uio.no>
	<20020930194227.A22095@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Marcelo Tosatti <marcelo@conectiva.com.br>,
	Chuck Lever <cel@netapp.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Linux FSdevel <linux-fsdevel@vger.kernel.org>,
	NFS maillist <nfs@lists.sourceforge.net>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20020930194227.A22095@infradead.org>
List-ID: <nfs.lists.sourceforge.net>

On Mon, 2002-09-30 at 19:42, Christoph Hellwig wrote:
> I don't think changing the filesystem entry points during 2.4 is an option.

Its not a very hard change and we've made bigger changes than this
during the 2.4 VFS code. It would be a good idea to be able to tell
cleanly which version of the interface is present
