Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.eu.citrix.com ([62.200.22.115]:28740 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757846Ab2AEUEh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Jan 2012 15:04:37 -0500
Subject: Re: [PATCH 5/6] net: add paged frag destructor support to
 kernel_sendpage.
From: Ian Campbell <Ian.Campbell@citrix.com>
To: David Miller <davem@davemloft.net>
CC: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
        "kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
        "pekkas@netcore.fi" <pekkas@netcore.fi>,
        "jmorris@namei.org" <jmorris@namei.org>,
        "yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
        "kaber@trash.net" <kaber@trash.net>,
        "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "gregkh@suse.de" <gregkh@suse.de>,
        "drbd-user@lists.linbit.com" <drbd-user@lists.linbit.com>,
        "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>,
        "cluster-devel@redhat.com" <cluster-devel@redhat.com>,
        "ocfs2-devel@oss.oracle.com" <ocfs2-devel@oss.oracle.com>,
        "ceph-devel@vger.kernel.org" <ceph-devel@vger.kernel.org>,
        "rds-devel@oss.oracle.com" <rds-devel@oss.oracle.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
In-Reply-To: <20120105.141522.1303730212186060591.davem@davemloft.net>
References: <1325783399.25206.413.camel@zakaz.uk.xensource.com>
	 <1325783624-14601-5-git-send-email-ian.campbell@citrix.com>
	 <20120105.141522.1303730212186060591.davem@davemloft.net>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Thu, 5 Jan 2012 20:04:34 +0000
Message-ID: <1325793874.29084.25.camel@dagon.hellion.org.uk>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2012-01-05 at 19:15 +0000, David Miller wrote:
> From: Ian Campbell <ian.campbell@citrix.com>
> Date: Thu, 5 Jan 2012 17:13:43 +0000
> 
> > -static ssize_t do_tcp_sendpages(struct sock *sk, struct page **pages, int poffset,
> > +static ssize_t do_tcp_sendpages(struct sock *sk,
> > +				struct page **pages,
> > +				struct skb_frag_destructor **destructors,
> > +				int poffset,
> >  			 size_t psize, int flags)
> >  {
> >  	struct tcp_sock *tp = tcp_sk(sk);
> 
> An array of destructors is madness, and the one call site that specifies this
> passes an address of a single entry.

I figured it was easy enough to accommodate the multiple destructor case
but you are right that is overkill given the current (and realistically,
expected) usage, I'll change that for the next round.

(that's assuming we don't end up with some scheme where the struct page
* is in the destructor struct like I was investigating previously to
alleviate the frag size overhead. I guess this illustrates nicely why
that approach got ugly: these array propagate all the way up the call
chain if you do that)

> This also would never even have to occur if you put the destructor inside of
> struct page instead.
> 
> Finally, except for the skb_shared_info() layout optimization in patch #1 which
> I alreayd applied, this stuff is not baked enough for the 3.3 merge window.

Sure thing, I should have made it clear in my intro mail that I was
aiming for 3.4.

Thanks,
Ian

