From: Kasparek Tomas <kasparek@fit.vutbr.cz>
Subject: Re: [PATCH 0/3] NFS regression in 2.6.26?, "task blocked for more
	than 120 seconds"
Date: Wed, 25 Mar 2009 09:46:39 +0100
Message-ID: <20090325084638.GM57805@fit.vutbr.cz>
References: <20090112090404.GL47559@fit.vutbr.cz> <1231782009.7322.12.camel@heimdal.trondhjem.org> <1231809446.7322.17.camel@heimdal.trondhjem.org> <20090113152201.GD47559@fit.vutbr.cz> <20090116104802.GF47559@fit.vutbr.cz> <20090118130835.GH47559@fit.vutbr.cz> <20090120150301.GG47559@fit.vutbr.cz> <1232465547.7055.3.camel@heimdal.trondhjem.org> <20090303120848.GV89843@fit.vutbr.cz> <1236089767.9631.4.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from kazi.fit.vutbr.cz ([147.229.8.12]:65072 "EHLO kazi.fit.vutbr.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756707AbZCYIqq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Mar 2009 04:46:46 -0400
In-Reply-To: <1236089767.9631.4.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 03, 2009 at 09:16:07AM -0500, Trond Myklebust wrote:
> On Tue, 2009-03-03 at 13:08 +0100, Kasparek Tomas wrote:
> > On Tue, Jan 20, 2009 at 10:32:27AM -0500, Trond Myklebust wrote:
> > > A binary wireshark dump of the traffic between one such client and the
> > > server would help.
> > 
> > I was able to finally got the tcpdump. I got it from 2.6.27.19 client but
> > after several weeks without problems. I include the file and place it on
> > http://merlin.fit.vutbr.cz/tmp/nfs/dump_kas2_mat.dump_small (have over 1GB
> > of dump, but it's all the time the same SYN+RST packets). The packet rate
> > maxed at 260000pps from two clients.
> > 
> > This dump is taken from server after reset (the server does not respond
> > even to keybord) before clients are disconnected/rebooted. To remind it - all
> > clients seems to work well with reversed
> > e06799f958bf7f9f8fae15f0c6f519953fb0257c
> 
> Yes. I saw that behaviour when testing at Connectathon last week. When
> one of the servers I was testing against crashed and later came up
> again, the patched client went into that same SYN+RST frenzy. I'm
> planning to look at this now that I'm back at home.

Hi Trond, is there something new about this? Having this solved will enable
me to test 2.6.27.x on more machines and hopefully solve the last lockd
problem.

Thank you in advance

--   

  Tomas Kasparek, PhD student  E-mail: kasparek@fit.vutbr.cz
  CVT FIT VUT Brno, L127       Web:    http://www.fit.vutbr.cz/~kasparek
  Bozetechova 1, 612 66        Fax:    +420 54114-1270
  Brno, Czech Republic         Phone:  +420 54114-1220

  jabber: tomas.kasparek-2ASvDZBniIelVyrhU4qvOw@public.gmane.org
  GPG: 2F1E 1AAF FD3B CFA3 1537  63BD DCBE 18FF A035 53BC

