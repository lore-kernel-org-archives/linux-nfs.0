Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.12.86]:46866 "EHLO
	tombraider.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757895Ab2FARKV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Jun 2012 13:10:21 -0400
Date: Fri, 1 Jun 2012 13:10:12 -0400
From: Jim Rees <rees@umich.edu>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Orion Poplawski <orion@cora.nwra.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Spurious rpc.idmapd nss_getpwnam: name 'nobody' does not map
 into domain messages
Message-ID: <20120601171012.GA9054@umich.edu>
References: <loom.20120601T174414-583@post.gmane.org>
 <1338566283.2774.19.camel@lade.trondhjem.org>
 <4FC8ED22.40508@cora.nwra.com>
 <1338568876.2774.25.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1338568876.2774.25.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Myklebust, Trond wrote:

  > Well, it's mapping it to "nobody" id 99:
  
  Yes, that's the correct thing to do if a user "nobody" exists.

Is it?  RFC3530 says "nobody" (on the wire) is the anonymous user.  If the
server has a real user whose local name is "nobody," should the nfs
anonymous user be mapped to the real local user named "nobody", or should it
be mapped to uid -2?

I'm inclined to say that if you have a real user named "nobody" on linux
then you get what you deserve.
