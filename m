From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] NFS regression in 2.6.26?, "task blocked for more than
 120 seconds"
Date: Tue, 25 Nov 2008 08:57:14 -0500
Message-ID: <1227621434.7057.33.camel@heimdal.trondhjem.org>
References: <20081017123207.GA14979@rabbit.intern.cm-ag>
	 <1224484046.23068.14.camel@localhost.localdomain>
	 <1225539927.2221.3.camel@localhost.localdomain>
	 <1225546878.4390.3.camel@heimdal.trondhjem.org>
	 <1227596962.16868.22.camel@localhost.localdomain>
	 <1227619696.7057.19.camel@heimdal.trondhjem.org>
	 <1227620339.9425.99.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, Max Kellermann <mk-xMchvyqCc6DQT0dZR+AlfA@public.gmane.org>,
	linux-kernel@vger.kernel.org, gcosta@redhat.com,
	Grant Coady <grant_lkml-rGYn+TmxqGy6c6uEtOJ/EA@public.gmane.org>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Tom Tucker <tom@opengridcomputing.com>
To: Ian Campbell <ijc-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:60095 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750963AbYKYN5U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Nov 2008 08:57:20 -0500
In-Reply-To: <1227620339.9425.99.camel-o4Be2W7LfRlXesXXhkcM7miJhflN2719@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2008-11-25 at 13:38 +0000, Ian Campbell wrote:
> > That would indicate that the server is failing to close the TCP
> > connection when the client closes on its end.
> > 
> > Could you remind me what server you are using?
> 
> 2.6.25-2-486 which is a Debian package from backports.org, changelog
> indicates that it contains 2.6.25.7.

Hmm... It should normally close sockets when the state changes. There
might be a race, though...

> > Also, does 'netstat -t'
> > show connections that are stuck in the CLOSE_WAIT state when you see the
> > hang?
> 
> I'd have to wait for it to reproduce again to be 100% sure but according
> to http://lkml.indiana.edu/hypermail/linux/kernel/0808.3/0120.html
> I was seeing connections in FIN_WAIT2 but not CLOSE_WAIT.

That would be on the client side. I'm talking about the server.

Cheers
  Trond

