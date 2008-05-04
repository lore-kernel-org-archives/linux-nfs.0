From: vinvin-CCKDRK/Hd0cdbCeoMzGj59i2O/JbrIOy@public.gmane.org (vincent)
Subject: Re: Text-based mount interface breaking non-UDP mounts
Date: Mon, 5 May 2008 00:39:34 +0200
Message-ID: <20080504223934.GA11746@vinvin.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bfields@fieldses.org
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp21.orange.fr ([80.12.242.46]:62349 "EHLO smtp21.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756786AbYEDWjh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 4 May 2008 18:39:37 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> Chuck Lever wrote:
> Thanks for the offer.  I tested against a server configuration that  
> dropped UDP packets, but I never tested through an ssh tunnel.

In the ssh tunnel case, what can be seen in network captures for
localhost on the client is that mounting requests are sent over UDP, and
since the ports are those specified for the ssh tunnel, they lead to
nothing on localhost UDP, and an ICMP dest unreach (port) is sent back.
This is made twice before mount.nfs exits with an internal error, 2
packets each time.

I have the same problem than Frank, using NFS through a ssh tunnel. It
was working with 2.6.20 and I've just upgraded to 2.6.25 and it does not
works anymore.


Vincent


