From: Frank Steiner <fsteiner-mail1-G0GEQqhI7DhYiKXMg8wJIg@public.gmane.org>
Subject: [NFS] locking failure with rpcbind and nfsroot (SLES 11, 2.6.27)
Date: Wed, 22 Jul 2009 15:57:50 +0200
Message-ID: <4A671ADE.5060109@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:57435 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754828AbZGVOYq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Jul 2009 10:24:46 -0400
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1MTckN-0003Q1-GY
	for linux-nfs@vger.kernel.org; Thu, 23 Jul 2009 00:24:43 +1000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

the question in short: How can I boot a diskless client with nfsroot and
let it mount its /var directory via NFS, with locking enabled?


We did this with SLES 10 so far:
- boot the client and let it mount / read-only from the server
- start portmap on the client
- execute sth. like "mount -o rw,lock server:/<clientip>/var /var"

Then we had file locking in /var on the client, and on every NFS directory
we mounted on the client afterwards.

With SLES 11 (kernel 2.6.27) we switched from portmap to rpcbind and things fail, 
because rpcbind creates a lock file and a socket in /var/run, so we need a
writeable /var before we can mount /var.

So we first create a tmpfs for /var, start rpcbind, then mount the clients
/var directory via NFS from the server over the tmpfs.

Then we try to restart rpcbind so that it can recreate the socket in /var/run,
but it fails. It doesn't create the socket file, and after about 60 seconds says:

rpcbind: server localhost not responding, timed out
lockd: cannot monitor our_server
lockd: failed to monitor our_server

So it seems we cannot mount a nfs directory on a tmpfs /var when this /var
is already used by rpcbind and its socket.

What can we do? Is /var as nfs directory with locking no longer possible
with nfsroot and rpcbind?

cu,
Frank

-- 
Dipl.-Inform. Frank Steiner   Web:  http://www.bio.ifi.lmu.de/~steiner/
Lehrstuhl f. Bioinformatik    Mail: http://www.bio.ifi.lmu.de/~steiner/m/
LMU, Amalienstr. 17           Phone: +49 89 2180-4049
80333 Muenchen, Germany       Fax:   +49 89 2180-99-4049
* Rekursion kann man erst verstehen, wenn man Rekursion verstanden hat. *

------------------------------------------------------------------------------
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

