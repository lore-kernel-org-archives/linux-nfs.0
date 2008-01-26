From: "Paul B. Henson" <henson@acm.org>
Subject: NFS over TCP idle timeout
Date: Fri, 25 Jan 2008 16:41:00 -0800 (PST)
Message-ID: <Pine.GSO.4.55.0801251516550.21@loogie.intranet.csupomona.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sparky.unx.csupomona.edu ([134.71.247.19]:54682 "EHLO
	sparky.unx.csupomona.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752490AbYAZAtn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Jan 2008 19:49:43 -0500
Received: from localhost (localhost [127.0.0.1])
	by sparky.unx.csupomona.edu (Postfix) with ESMTP id 06FE1DC0CF
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 16:41:06 -0800 (PST)
Received: from sparky.unx.csupomona.edu ([127.0.0.1])
	by localhost (sparky.unx.csupomona.edu [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id mydaUzn2plgw for <linux-nfs@vger.kernel.org>;
	Fri, 25 Jan 2008 16:41:05 -0800 (PST)
Received: from loogie.intranet.csupomona.edu (loogie.intranet.csupomona.edu [134.71.184.48])
	(using TLSv1 with cipher EDH-RSA-DES-CBC3-SHA (168/168 bits))
	(No client certificate requested)
	by sparky.unx.csupomona.edu (Postfix) with ESMTP id D56D0DC0B5
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 16:41:00 -0800 (PST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Does the Linux server implementation of NFS over TCP implement an idle
timeout that automatically disconnects clients after some amount of
inactivity?

I was testing NFSv4 from a Solaris 10 client to a Linux server (Gentoo,
2.6.20). The Solaris client does not tear down the TCP connection upon
system shutdown, which leaves an orphaned established TCP connection on the
server. The connection remained in the established state for days.

Sun support indicates their server automatically disconnects idle clients,
and don't consider not closing the client connection upon shutdown a bug.

I didn't find any documentation regarding the Linux implementation and idle
timeouts, although I did find the following code in net/sunrpc/svcsock.c:

-----
/* apparently the "standard" is that clients close
 * idle connections after 5 minutes, servers after
 * 6 minutes
 *   http://www.connectathon.org/talks96/nfstcp.pdf
 */
static int svc_conn_age_period = 6*60;
-----

that would seem to indicate it should close the connection after some
amount of idle time? However, empirically that doesn't seem to happen.

Should idle connections automatically be closed? Are there any tunables or
switches that need to be touched to enable that?

Thanks...


-- 
Paul B. Henson  |  (909) 979-6361  |  http://www.csupomona.edu/~henson/
Operating Systems and Network Analyst  |  henson@csupomona.edu
California State Polytechnic University  |  Pomona CA 91768
