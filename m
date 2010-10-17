Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from sachiko.kuiki.net ([80.68.89.100]:39608 "EHLO sachiko.kuiki.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753521Ab0JQOgL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 17 Oct 2010 10:36:11 -0400
Received: from localhost (unknown [76.14.51.87])
	by sachiko.kuiki.net (Postfix) with ESMTP id 1EED6C44B
	for <linux-nfs@vger.kernel.org>; Sun, 17 Oct 2010 14:29:22 +0000 (UTC)
Date: Sun, 17 Oct 2010 07:29:19 -0700
From: Jonathan Steinert <hachi@kuiki.net>
To: linux-nfs@vger.kernel.org
Subject: nfsd rpc service update failures on 2.6.32
Message-ID: <20101017142918.GA6805@miyako>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi folks, I've got a machine here that I've been debugging NFS issues on for a week or so now.

I've boiled the issue down to this:

Start up the NFS server, this seems to work fine, no errors:
  rpc.nfsd 1

Check to see if nfsd has registered with rpcbind, this never shows the nfsd service being registered:
  rpcinfo -p

So far I've got the following diagnostics done:

- Cranked up the debugging in rpcbind, never found SET updates happening (only UNSET)
- Captured the rpc update frames going over lo, viewed in wireshark. They are all UNSET only
- Crank up rpcdebug on kernel, only unregister frames are being generated.

The interesting thing I see is:

svc: svc_register(nfsdv4, udp, 0, 2)
RPC:       unregistering [100003, 4, 0.0.0.0.0.0, 'udp'] with local rpcbind

For some reason svc_register is being called with '0' as the port argument.

Looking at the ports list in proc says that udp and tcp 2049 are to be used.

I've been searching around for any information regarding this issue, but haven't found anything. Do any of you folks know if this has been fixed in a later kernel? Is this even a known issue of some kind? I would be testing a newer kernel, but my box has a major issue with some driver as of 2.6.33, which I am also still debugging.

Not subscribed to this list, please CC me if you can. I'll watch the archives too.

Thanks much

--hachi

------------------------------------------------------------------------
"She smiled again, shrugged her shoulders, and became a perfect mirror."
------------------------------------------------------------------------
