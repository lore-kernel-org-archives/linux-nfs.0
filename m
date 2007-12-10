From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] [PATCH] xprtrdma: fix XDR tail buf marshalling for all
	ops
Date: Mon, 10 Dec 2007 11:29:04 -0500
Message-ID: <1197304144.10573.6.camel@heimdal.trondhjem.org>
References: <Pine.LNX.4.64.0711291521010.7142@jlentini-linux.nane.netapp.com>
	 <1196902607.17724.2.camel@heimdal.trondhjem.org>
	 <Pine.LNX.4.64.0712061255200.12638@jlentini-linux.nane.netapp.com>
	 <1196969392.7990.9.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0712061803240.12638@jlentini-linux.nane.netapp.com>
	 <EXNANE01G5aYY61LEdy00000ae1@exnane01.hq.netapp.com>
	 <1197300897.21931.9.camel@trinity.ogc.int>
	 <1197303835.10573.3.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Talpey, Thomas" <Thomas.Talpey@netapp.com>,
	linux-nfs@vger.kernel.org, nfs@lists.sourceforge.net
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:57718 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752533AbXLJQ3J (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Dec 2007 11:29:09 -0500
In-Reply-To: <1197303835.10573.3.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mon, 2007-12-10 at 11:23 -0500, Trond Myklebust wrote:

> Look at the damned thing. _Every_ chunk in it has an 'if (read)' else.
> It that is 'similar logic' then I'm a duck.

..or to spell it out:


 while (1) {
  if (Trond)
    write_sarky_mail();
  else
    quack();
 }

is not a sign of 'similar logic'. It just means that both Trond and
ducks do the same thing over and over again.

Trond

