From: Neil Brown <neilb@suse.de>
Subject: [grumble] connected UDP sockets [grumble] Solaris [grumble]
Date: Thu, 23 Oct 2008 14:57:15 +1100
Message-ID: <18687.63003.966163.267177@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:35969 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752255AbYJWD5G (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Oct 2008 23:57:06 -0400
Received: from Relay1.suse.de (relay-ext.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id 531B44649B
	for <linux-nfs@vger.kernel.org>; Thu, 23 Oct 2008 05:57:04 +0200 (CEST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


The attentive reader of this mailing list may be aware that I was -
some time ago - advocating using connected UDP sockets when UDP was
used to contact the server during a mount. i.e. to talk to portmap and
mountd.

The benefit of this is that errors reported by ICMP (e.g. host
unreachable / port unreachable) are reported to the application with
connected sockets, whereas unconnected sockets need to wait for a
timeout.

I just discovered that there is a problem with this.  It involves
multihomed hosts and certain non-Linux operating systems such as
Solaris (I don't know which version(s)).

In one particular case, the UDP request (portmap lookup I assume) was
sent from a Linux client to a Solaris server and the reply promptly
came back from a different IP address (presumably the address of the
interface that Solaris wanted to route through to get to the client).
Linux replied to this with an ICMP error.  It couldn't send the reply
to mount.nfs because mount.nfs had a connected UDP sockets that was
connected to a different remote address.

This is arguably a bug in Solaris.  It should reply with a source
address matching the destination address of the request.  Linux hasn't
had that bug for years.  But we probably still have to live with it.

The conclusion is that if we use connected UDP sockets, we will get
unnecessary timeout talking to certain multihomed hosts, and if we
don't we will get unnecessary timeouts talking to certain hosts that
don't support portmap on UDP (for example).

I don't suppose there is a middle ground?  A semi-connected socket?
Or we could have one of each and see which one gets a reply first?
No, that's just yuck.


Much as it pains me to say this, maybe we just need to treat UDP as
legacy for all protocols (PORTMAP, MOUNT, NLM, NSM), not just NFS.
None of these problems occur with TCP.  TCP does have a slightly
higher overhead for simple transactions, but it is a cost that is
unlikely to be noticeable in reality.


Thoughts?

NeilBrown (grumble grumble).
