Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:36895 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756880Ab3GQTKs convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Jul 2013 15:10:48 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Subject: Re: Error writing to nfs4 with 3.11-rc1
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAHsu+b_hhSr2vwcwM8TX3=xF=3HffUXG=YLVLcsEpH1wHn+JoA@mail.gmail.com>
Date: Wed, 17 Jul 2013 15:10:43 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <A5C56FD6-9E14-43A3-8627-1C8F77EC6926@oracle.com>
References: <CAHsu+b_hhSr2vwcwM8TX3=xF=3HffUXG=YLVLcsEpH1wHn+JoA@mail.gmail.com>
To: Andre Heider <a.heider@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 17, 2013, at 2:55 PM, Andre Heider <a.heider@gmail.com> wrote:

> Hi,
> 
> I'm having problems using 3.11-rc1 as nfs4 client (with a FreeBSD 9.1
> server) using sec=sys.
> 
> With the same server+client setup, just booting different kernels:
> 3.9.10 works without issues
> 3.10.1 works too, but introduced "RPC: AUTH_GSS upcall timed out." in
> dmesg (iirc I don't need gss with sec=sys)

Not a requirement, but running gssd should make that message go away.  The client is attempting to use krb5i to manage its lease on the server, and falling back to AUTH_UNIX when it sees gssd is not running.

> 3.11-rc1 reading from the server still works, writing fails
> 
> Even a simple touch on the share fails with:
> touch: cannot touch ‘/mnt/andre/test’: Input/output error

A network capture is a reasonable place to start.

  # tcpdump -s0 -w /tmp/raw

Then try your touch test again.  Stop the tcpdump.  You can post a compressed version of the raw dump here if it's short.

> mount output of the share in question:
> 192.168.0.1:/home/andre on /mnt/andre type nfs4
> (rw,nosuid,relatime,vers=4.0,rsize=65536,wsize=65536,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=192.168.0.40,local_lock=none,addr=192.168.0.1)
> 
> The 3.11 .config was cp'ed from 3.10.1 and updated via `make
> oldconfig`. Toggling the 3.11 nfs4.2 kernel options doesn't seem to
> make a difference.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




