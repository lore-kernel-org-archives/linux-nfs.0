Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:29652 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754311Ab1JQV5v convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Oct 2011 17:57:51 -0400
Subject: Re: 4.1 client reconnect bug
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Date: Mon, 17 Oct 2011 14:57:52 -0700
In-Reply-To: <20111017210408.GA13368@fieldses.org>
References: <20111017210408.GA13368@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1318888672.2753.43.camel@lade.trondhjem.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2011-10-17 at 17:04 -0400, J. Bruce Fields wrote: 
> Following up on a pub conversation from a couple weeks ago:
> 
> The client apparently assumes that (in the absence of state protection)
> sending a SEQUENCE over a new tcp connection to the server automatically
> associates the new tcp connection with both the forechannel and
> backchannel of the session.
> 
> The server currently assumes that the new tcp connection should be
> associated only with the forechannel.
> 
> RFC 5661 sides with the forechannel-only convention:
> 
> 	- 2.6.10.6.2: "If the client wants to use additional connections
> 	  for the backchannel, then it needs to call
> 	  BIND_CONN_TO_SESSION on each connection it wants to use with
> 	  the session."
> 
> 	- 2.10.13.1.2: "If the connection that was lost was the last one
> 	  associated with the backchannel, and the client wants to
> 	  retain the backchannel and/or prevent revocation of recallable
> 	  state, the client needs to reconnect, and if it does, it MUST
> 	  associate the connection to the session and backchannel via
> 	  BIND_CONN_TO_SESSION."
> 
> 	- 18.34.3: "If, when the client ID was created, the client opted
> 	  for SP4_NONE state protection, the client is not required to
> 	  use BIND_CONN_TO_SESSION to associate the connection with the
> 	  session, unless the client wishes to associate the connection
> 	  with the backchannel."
> 
> That means that currently if the client attempts to reconnect (e.g. to
> resend a timed-out rpc), it will see SEQ4_STATUS_CB_PATH_DOWN_SESSION
> set on future SEQUENCE replies.

Agreed, however in this case the BIND_CONN_TO_SESSION can be treated as
an optimisation. We should fix it soon, but as long as the existing
clients handle the path down error correctly (which we do by starting a
recovery thread, then resetting the session), then we are able to
function.

IOW: This is something that was on our 'B' list of items to complete
(i.e. after basic session+pnfs functionality)...

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

