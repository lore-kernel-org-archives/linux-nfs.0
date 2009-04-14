Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from kazi.fit.vutbr.cz ([147.229.8.12]:58750 "EHLO kazi.fit.vutbr.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753102AbZDNNe0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Apr 2009 09:34:26 -0400
Date: Tue, 14 Apr 2009 15:34:23 +0200
From: Kasparek Tomas <kasparek@fit.vutbr.cz>
To: Bryan McLellan <btm@loftninjas.org>, linux-nfs@vger.kernel.org
Subject: Re: Unexplained NFS mount hangs
Message-ID: <20090414133422.GU8106@fit.vutbr.cz>
References: <20090413092406.304d04fb@dstickney2> <C81F82EF-81F0-432D-B727-F496F807CEB3@oracle.com> <20090413104759.525161b2@dstickney2> <893823750904131611i70621c5t4c5f96d3a9e876e7@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <893823750904131611i70621c5t4c5f96d3a9e876e7@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Apr 13, 2009 at 04:11:35PM -0700, Bryan McLellan wrote:
> On Mon, Apr 13, 2009 at 9:47 AM, Daniel Stickney <dstickney@pronto.com> wrote:
> > To add a little more info, in a post on April 10th titled "NFSv3 Client Timeout on 2.6.27" Bryan mentioned that his client socket was in state FIN_WAIT2, and server in CLOSE_WAIT, which is exactly what I am seeing here.
> 
> Since my problems originated after upgrading to Ubuntu intrepid in a
> 'etch -> hardy -> intrepid' cycle, and hardy contained 2.6.24, I
> wonder if the regression was in:
> 
> commit e06799f958bf7f9f8fae15f0c6f519953fb0257c
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Mon Nov 5 15:44:12 2007 -0500
> 
>     SUNRPC: Use shutdown() instead of close() when disconnecting a TCP socket
> 
>     By using shutdown() rather than close() we allow the RPC client to wait
>     for the TCP close handshake to complete before we start trying to reconnect
>     using the same port.
>     We use shutdown(SHUT_WR) only instead of shutting down both directions,
>     however we wait until the server has closed the connection on its side.
> 
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

Hi,

probably yes, I have several other problems with this. See my previous post
about lockd issues and DoS on server by repeating clients. Last info is,
that Trond knows about the DoS problem and when this is solved I will try
to do everything I can to solve the lockd problem. I need to stay with
2.6.27 so it is crucial for me to solve all these.

Bye

--   

  Tomas Kasparek, PhD student  E-mail: kasparek@fit.vutbr.cz
  CVT FIT VUT Brno, L127       Web:    http://www.fit.vutbr.cz/~kasparek
  Bozetechova 1, 612 66        Fax:    +420 54114-1270
  Brno, Czech Republic         Phone:  +420 54114-1220

  jabber: tomas.kasparek@jabber.cz
  GPG: 2F1E 1AAF FD3B CFA3 1537  63BD DCBE 18FF A035 53BC

