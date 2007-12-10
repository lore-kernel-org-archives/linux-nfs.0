From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [NFS] [PATCH] xprtrdma: fix XDR tail buf marshalling for all
	ops
Date: Mon, 10 Dec 2007 11:14:26 -0600
Message-ID: <1197306866.21931.16.camel@trinity.ogc.int>
References: <Pine.LNX.4.64.0711291521010.7142@jlentini-linux.nane.netapp.com>
	 <1196902607.17724.2.camel@heimdal.trondhjem.org>
	 <Pine.LNX.4.64.0712061255200.12638@jlentini-linux.nane.netapp.com>
	 <1196969392.7990.9.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0712061803240.12638@jlentini-linux.nane.netapp.com>
	 <EXNANE01G5aYY61LEdy00000ae1@exnane01.hq.netapp.com>
	 <1197300897.21931.9.camel@trinity.ogc.int>
	 <1197303835.10573.3.camel@heimdal.trondhjem.org>
	 <1197304144.10573.6.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Talpey, Thomas" <Thomas.Talpey@netapp.com>,
	linux-nfs@vger.kernel.org, nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:43132 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751941AbXLJRJf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2007 12:09:35 -0500
In-Reply-To: <1197304144.10573.6.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mon, 2007-12-10 at 11:29 -0500, Trond Myklebust wrote:
> On Mon, 2007-12-10 at 11:23 -0500, Trond Myklebust wrote:
> 
> > Look at the damned thing. _Every_ chunk in it has an 'if (read)' else.
> > It that is 'similar logic' then I'm a duck.
> 
> ..or to spell it out:
> 

> 
>  while (1) {
>   if (Trond)
>     write_sarky_mail();
>   else
>     quack();
>  }
> 
> is not a sign of 'similar logic'. It just means that both Trond and
> ducks do the same thing over and over again.


Ok, fair enough. It's a mix. What is combined is the encapsulating loop,
calls to memory registration and call to convert_iovs. But you are
correct, inside and outside the loop where the chunks are actually
formatted, there are if statements to discriminate the chunk type.

Quack-quack,
Tom

> 
> Trond
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

