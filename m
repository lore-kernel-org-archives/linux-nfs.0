Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:42291 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755181Ab1JQVEJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Oct 2011 17:04:09 -0400
Date: Mon, 17 Oct 2011 17:04:08 -0400
To: Trond Myklebust <trond@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: 4.1 client reconnect bug
Message-ID: <20111017210408.GA13368@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Following up on a pub conversation from a couple weeks ago:

The client apparently assumes that (in the absence of state protection)
sending a SEQUENCE over a new tcp connection to the server automatically
associates the new tcp connection with both the forechannel and
backchannel of the session.

The server currently assumes that the new tcp connection should be
associated only with the forechannel.

RFC 5661 sides with the forechannel-only convention:

	- 2.6.10.6.2: "If the client wants to use additional connections
	  for the backchannel, then it needs to call
	  BIND_CONN_TO_SESSION on each connection it wants to use with
	  the session."

	- 2.10.13.1.2: "If the connection that was lost was the last one
	  associated with the backchannel, and the client wants to
	  retain the backchannel and/or prevent revocation of recallable
	  state, the client needs to reconnect, and if it does, it MUST
	  associate the connection to the session and backchannel via
	  BIND_CONN_TO_SESSION."

	- 18.34.3: "If, when the client ID was created, the client opted
	  for SP4_NONE state protection, the client is not required to
	  use BIND_CONN_TO_SESSION to associate the connection with the
	  session, unless the client wishes to associate the connection
	  with the backchannel."

That means that currently if the client attempts to reconnect (e.g. to
resend a timed-out rpc), it will see SEQ4_STATUS_CB_PATH_DOWN_SESSION
set on future SEQUENCE replies.

--b.
