From: "David S. Miller" <davem@redhat.com>
Subject: Re: [NFS] [PATCH][RFC] use completions instead of sleep_on
 forrpciod
Date: Mon, 9 Feb 2004 13:00:36 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040209130036.613a9bdd.davem@redhat.com>
References: <20040207144405.GA19416@lst.de>
	<20040209102801.GC21364@suse.de>
	<35059.80.213.3.64.1076359739.squirrel@webmail.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: okir@suse.de, hch@lst.de, netdev@oss.sgi.com, nfs@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: trond.myklebust@fys.uio.no
In-Reply-To: <35059.80.213.3.64.1076359739.squirrel@webmail.uio.no>
Errors-to: netdev-bounce@oss.sgi.com
List-ID: <nfs.lists.sourceforge.net>

On Mon, 9 Feb 2004 21:48:59 +0100 (CET)
trond.myklebust@fys.uio.no wrote:

> I'll admit that the rpciod killer code is racy, but I'm not sure that
> completions are the best answer, as they have at least one nasty feature:
> they are not interruptible.

Would you like to back out the change then?  I put it into
Linus's tree already.
