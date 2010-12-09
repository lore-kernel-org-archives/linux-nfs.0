Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:3264 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755989Ab0LINOl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Dec 2010 08:14:41 -0500
Message-ID: <4D00D63F.5010904@panasas.com>
Date: Thu, 09 Dec 2010 15:14:39 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: NFS list <linux-nfs@vger.kernel.org>, nfsv4 <nfsv4@ietf.org>
Subject: layout state simulator
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

In order to help with verifying the layout-related algorithms presented
in RFC5661 I've built a simple simulator that generates random layout operations,
implements them on the server side and applies the results on the client side.
The simulator then verifies the resulting layout on both sides of the wire
to make sure they agree on the layout stateid and on the contents of the layout,
so that the client does not hold layout it is not supposed to.

So far, I've checked combinations of LAYOUTGET and LAYOUTRETURN and the only
addition to the protocol that was required was the serialization of the initial
LAYOUTGET carrying a non-layout stateid.
The reason for that, even without a forgetful client, is that in case the client sent
multiple layoutgets with the initial stateid and a layoutreturn that returns everything
(and thus resetting the layout stateid), without waiting for all the initial layoutgets,
then there will be a mixture of layout stateids before and after the layoutreturn
with colliding seqids.

I've implemented a simple synchronization scheme allowing a single layoutget with the
initial stateid although in theory we could allow multiple such layoutgets in parallel,
just fully serialized against a conflicting layoutreturn.  If we allow forgetful clients
to send a layoutget with the initial stateid to signal a "reset" of the layout (e.g., an
implicit layoutreturn for the whole file), it should be a singular operation as well.

The simulator is freely available (under GPLv2) here:
git://linux-nfs.org/~bhalevy/layout-sim.git

Next on my list are:
- CB_LAYOUTRECALL
- forgetful client
- return_on_close

Please feel free to use and improve it!

Benny
