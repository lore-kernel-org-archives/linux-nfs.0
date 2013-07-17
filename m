Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f41.google.com ([209.85.160.41]:45947 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756095Ab3GQSzh convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Jul 2013 14:55:37 -0400
Received: by mail-pb0-f41.google.com with SMTP id rp16so2235169pbb.14
        for <linux-nfs@vger.kernel.org>; Wed, 17 Jul 2013 11:55:37 -0700 (PDT)
MIME-Version: 1.0
Date: Wed, 17 Jul 2013 20:55:36 +0200
Message-ID: <CAHsu+b_hhSr2vwcwM8TX3=xF=3HffUXG=YLVLcsEpH1wHn+JoA@mail.gmail.com>
Subject: Error writing to nfs4 with 3.11-rc1
From: Andre Heider <a.heider@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I'm having problems using 3.11-rc1 as nfs4 client (with a FreeBSD 9.1
server) using sec=sys.

With the same server+client setup, just booting different kernels:
3.9.10 works without issues
3.10.1 works too, but introduced "RPC: AUTH_GSS upcall timed out." in
dmesg (iirc I don't need gss with sec=sys)
3.11-rc1 reading from the server still works, writing fails

Even a simple touch on the share fails with:
touch: cannot touch ‘/mnt/andre/test’: Input/output error

mount output of the share in question:
192.168.0.1:/home/andre on /mnt/andre type nfs4
(rw,nosuid,relatime,vers=4.0,rsize=65536,wsize=65536,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=192.168.0.40,local_lock=none,addr=192.168.0.1)

The 3.11 .config was cp'ed from 3.10.1 and updated via `make
oldconfig`. Toggling the 3.11 nfs4.2 kernel options doesn't seem to
make a difference.

Any ideas?

Thanks,
Andre
