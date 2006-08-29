From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [NFS] kthread: update lockd to use kthread
Date: Tue, 29 Aug 2006 12:50:44 +0100
Message-ID: <20060829115044.GA26794@infradead.org>
References: <44EEA5E5.6000509@fr.ibm.com> <20060825135824.GA10659@infradead.org> <44EF2E6F.1040905@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964959AbWH2Lur@vger.kernel.org>
To: Cedric Le Goater <clg@fr.ibm.com>
In-Reply-To: <44EF2E6F.1040905@fr.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Fri, Aug 25, 2006 at 07:07:59PM +0200, Cedric Le Goater wrote:
> This kernel thread is a sub thread of the lockd thread. It's a bit more
> simple and does not require as much modification. It still depends on the
> way its parent is killed and it will require some more work when the sunrpc
> thread are fixed.

Yes, the whole sunrpc/nfs thread situation is rather difficult.

> The SIGKILL used to terminate the threads is a challenge ... it propagates
> to sub threads. Some other stuff that bother me in using the kthread api in
> sunrpc : nfs_callback_down() uses a wait on a completion with a timeout.
> This is not possible with the kthread but might not be really useful. dunno.

The usage look buggy to me because we can't guarantee thread exit.  But
I really don't even understand the requirements for those threads yet,
I wish someone could write up a coherent description.
