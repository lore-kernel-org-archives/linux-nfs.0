From: Ian Campbell <ijc-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>
Subject: Re: [PATCH] NFS regression in 2.6.26?, "task blocked for more than
	120 seconds"
Date: Tue, 25 Nov 2008 14:04:37 +0000
Message-ID: <1227621877.9425.102.camel@zakaz.uk.xensource.com>
References: <20081017123207.GA14979@rabbit.intern.cm-ag>
	 <1224484046.23068.14.camel@localhost.localdomain>
	 <1225539927.2221.3.camel@localhost.localdomain>
	 <1225546878.4390.3.camel@heimdal.trondhjem.org>
	 <1227596962.16868.22.camel@localhost.localdomain>
	 <1227619696.7057.19.camel@heimdal.trondhjem.org>
	 <1227620339.9425.99.camel@zakaz.uk.xensource.com>
	 <1227621434.7057.33.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, Max Kellermann <mk-xMchvyqCc6DQT0dZR+AlfA@public.gmane.org>,
	linux-kernel@vger.kernel.org, gcosta@redhat.com,
	Grant Coady <grant_lkml-rGYn+TmxqGy6c6uEtOJ/EA@public.gmane.org>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Tom Tucker <tom@opengridcomputing.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mtaout01-winn.ispmail.ntl.com ([81.103.221.47]:9439 "EHLO
	mtaout01-winn.ispmail.ntl.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752927AbYKYOE6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Nov 2008 09:04:58 -0500
In-Reply-To: <1227621434.7057.33.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2008-11-25 at 08:57 -0500, Trond Myklebust wrote:
> On Tue, 2008-11-25 at 13:38 +0000, Ian Campbell wrote:
> > > That would indicate that the server is failing to close the TCP
> > > connection when the client closes on its end.
> > > 
> > > Could you remind me what server you are using?
> > 
> > 2.6.25-2-486 which is a Debian package from backports.org, changelog
> > indicates that it contains 2.6.25.7.
> 
> Hmm... It should normally close sockets when the state changes. There
> might be a race, though...
> 
> > > Also, does 'netstat -t'
> > > show connections that are stuck in the CLOSE_WAIT state when you see the
> > > hang?
> > 
> > I'd have to wait for it to reproduce again to be 100% sure but according
> > to http://lkml.indiana.edu/hypermail/linux/kernel/0808.3/0120.html
> > I was seeing connections in FIN_WAIT2 but not CLOSE_WAIT.
> 
> That would be on the client side. I'm talking about the server.

Ah, OK. I'll abort my current test of 2.6.26+revert and wait for a repro
so I can netstat the server, give me a couple of days...

Ian.
-- 
Ian Campbell

It is more rational to sacrifice one life than six.
		-- Spock, "The Galileo Seven", stardate 2822.3

