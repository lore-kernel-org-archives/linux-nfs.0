From: Kasparek Tomas <kasparek@fit.vutbr.cz>
Subject: Re: [PATCH 0/3] NFS regression in 2.6.26?, "task blocked for more
	than 120 seconds"
Date: Tue, 2 Dec 2008 17:26:25 +0100
Message-ID: <20081202162625.GM47559@fit.vutbr.cz>
References: <1227596962.16868.22.camel@localhost.localdomain> <1227619696.7057.19.camel@heimdal.trondhjem.org> <1227620339.9425.99.camel@zakaz.uk.xensource.com> <1227621434.7057.33.camel@heimdal.trondhjem.org> <1227621877.9425.102.camel@zakaz.uk.xensource.com> <1227737539.31008.2.camel@localhost.localdomain> <1228090631.7112.11.camel@heimdal.trondhjem.org> <1228091380.7112.17.camel@heimdal.trondhjem.org> <20081202152256.GI47559@fit.vutbr.cz> <1228232222.3090.5.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ian Campbell <ijc-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>, linux-nfs@vger.kernel.org,
	Max Kellermann <mk-xMchvyqCc6DQT0dZR+AlfA@public.gmane.org>, linux-kernel@vger.kernel.org,
	gcosta@redhat.com, "J. Bruce Fields" <bfields@fieldses.org>,
	Tom Tucker <tom@opengridcomputing.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from kazi.fit.vutbr.cz ([147.229.8.12]:51027 "EHLO kazi.fit.vutbr.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751348AbYLBQ01 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Dec 2008 11:26:27 -0500
In-Reply-To: <1228232222.3090.5.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 02, 2008 at 10:37:02AM -0500, Trond Myklebust wrote:
> On Tue, 2008-12-02 at 16:22 +0100, Kasparek Tomas wrote:
> > On Sun, Nov 30, 2008 at 07:29:40PM -0500, Trond Myklebust wrote:
> > > On Sun, 2008-11-30 at 19:17 -0500, Trond Myklebust wrote:
> > > > Can you see if the following 3 patches help? They're against 2.6.28-rc6,
> > > > but afaics the problems are pretty much the same on 2.6.26.
> > > 
> > > Sorry... I forgot to add that these 3 patches need to be applied to the
> > > nfs server, not the client.
> > 
> > Hi,
> > 
> > I have the problem on client side and can not change server (FreeBSD 7.0). 
> > these patches does not change the situation (and they are probably not
> > supposed to do so, just giving it a try). After few minutes I got this on
> > the client with 2.6.28-rc6 with patches:
> > 
> > tcp   0   0 147.229.12.146:674          147.229.176.14:2049     FIN_WAIT2
> > 
> > Applying reverse e06799f958bf7f9f8fae15f0c6f519953fb0257c suggested by Ian
> > does help on the other side (with 2.6.27.4).
> 
> Then I suggest working around the problem by reducing the value of the
> sysctl net.ipv4.tcp_fin_timeout on the client.

Did tried. The number should be seconds and defaults to 60, These
connections are still there after several hours. Changing it to 10 (sec)
and same behaviour. (BTW The server did not changed in last several months)

--   

  Tomas Kasparek, PhD student  E-mail: kasparek@fit.vutbr.cz
  CVT FIT VUT Brno, L127       Web:    http://www.fit.vutbr.cz/~kasparek
  Bozetechova 1, 612 66        Fax:    +420 54114-1270
  Brno, Czech Republic         Phone:  +420 54114-1220

  jabber: tomas.kasparek-2ASvDZBniIelVyrhU4qvOw@public.gmane.org
  GPG: 2F1E 1AAF FD3B CFA3 1537  63BD DCBE 18FF A035 53BC

