From: Tomas Kasparek <kasparek@fit.vutbr.cz>
Subject: Re: [PATCH] NFS regression in 2.6.26?,
Date: Wed, 26 Nov 2008 09:16:07 +0000 (UTC)
Message-ID: <loom.20081126T070326-511@post.gmane.org>
References: <20081017123207.GA14979@rabbit.intern.cm-ag>  <1224484046.23068.14.camel@localhost.localdomain>  <1225539927.2221.3.camel@localhost.localdomain>  <1225546878.4390.3.camel@heimdal.trondhjem.org>  <1227596962.16868.22.camel@localhost.localdomain>  <1227619696.7057.19.camel@heimdal.trondhjem.org> <1227620339.9425.99.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:50141 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750823AbYKZKKF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Nov 2008 05:10:05 -0500
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1L5HLO-0008Cp-Vo
	for linux-nfs@vger.kernel.org; Wed, 26 Nov 2008 10:10:03 +0000
Received: from pckasparek.fit.vutbr.cz ([147.229.12.35])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 26 Nov 2008 10:10:02 +0000
Received: from kasparek by pckasparek.fit.vutbr.cz with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 26 Nov 2008 10:10:02 +0000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ian Campbell <ijc@...> writes:

> According to bisect:
> commit e06799f958bf7f9f8fae15f0c6f519953fb0257c
> Author: Trond Myklebust <Trond.Myklebust@...>
> Date:   Mon Nov 5 15:44:12 2007 -0500
>     SUNRPC: Use shutdown() instead of close() when disconnecting a TCP 

Hi, it seems I have the same problem, with slightly different config. Client is
2.6.24.7 (OK), 2.6.25-rc1 and later (25,26,27,28-rc6) (fail). On client I get
FIN_WAIT2 state. The server is FreeBSD 7.0-STABLE (have two of them with the
same behavior). Fastest way to get into trouble is to use automounter so it
cycles the ports - when it gets to one in FIN_WAIT2 the machine gets "dead".

Reversing the patch with 2.6.27.4 seems to help, before the machine gets stuck
in ~ hour, now it is up for 16hours and seems ok.

> > That would indicate that the server is failing to close the TCP
> > connection when the client closes on its end.

Once or twice I prove with tcpdump that client send FIN, got ACK from server but
no FIN from server.

Tom

