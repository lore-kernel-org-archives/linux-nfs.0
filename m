Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f41.google.com ([209.85.214.41]:51018 "EHLO
        mail-it0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751492AbeEDQ6h (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 4 May 2018 12:58:37 -0400
Received: by mail-it0-f41.google.com with SMTP id p3-v6so4181450itc.0
        for <linux-nfs@vger.kernel.org>; Fri, 04 May 2018 09:58:36 -0700 (PDT)
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: Re: RDMA connection lost and not re-opened
From: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <pcg4b0$qcc$1@blaine.gmane.org>
Date: Fri, 4 May 2018 12:58:34 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <A9E63254-22F5-48A7-85C2-8016D85CD192@gmail.com>
References: <pcg4b0$qcc$1@blaine.gmane.org>
To: scar <scar@drigon.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On May 3, 2018, at 7:02 PM, scar <scar@drigon.com> wrote:
> 
> I did also notice these errors on the NFS server 10.10.11.10:
> 
> May  2 21:27:59 pac kernel: svcrdma: failed to send reply chunks, rc=-5
> May  2 21:27:59 pac kernel: nfsd: peername failed (err 107)!
> May  2 21:27:59 pac kernel: nfsd: peername failed (err 107)!
> May  2 21:27:59 pac kernel: nfsd: peername failed (err 107)!
> May  2 21:27:59 pac kernel: nfsd: peername failed (err 107)!
> May  2 21:27:59 pac kernel: nfsd: peername failed (err 107)!
> May  2 21:27:59 pac kernel: nfsd: peername failed (err 107)!
> May  2 21:27:59 pac kernel: nfsd: peername failed (err 107)!
> May  2 21:27:59 pac kernel: nfsd: peername failed (err 107)!
> May  2 21:27:59 pac kernel: nfsd: peername failed (err 107)!
> May  2 21:27:59 pac kernel: nfsd: peername failed (err 107)!

Thanks for checking on the server side.

These timestamps don't line up with the client messages you posted
yesterday, the unmatched "closed (-103)" message being at 21:14:42.

"peername failed" is from the NFSD TCP accept path. I don't immediately
see how that is related to an NFS/RDMA mount. However, it might indicate
there was an HCA or fabric issue around that time that affected both
NFS/RDMA and IP-over-IB.

"failed to send reply chunks" would be expected if the RDMA connection
is lost before the server can send an RPC reply. It doesn't explain why
the connection is lost, however.

There don't seem to be any other probative messages on either system;
I'm looking for reports of flushed Send or Receive WRs, QP errors, or
DMAR faults. And of course any BUG output.

I assume you are running CentOS 6.9 on both the client and server
systems. That's a fairly old NFS/RDMA implementation, and one that I'm
not familiar with. RHEL 6 forked from upstream at 2.6.39, but then
parts of more recent upstream were backported to it, so now it is only
loosely related to what's currently in upstream, and all of that done
before I was deeply involved in NFS/RDMA upstream. Because of this
divergence we typically recommend that such reports be addressed first
to an appropriate Linux distributor who is responsible for the content
of that kernel.

In any event I don't think there's much you can do about a stuck mount
in this configuration, and you will have to reboot (perhaps even power
on reset) your client to recover.

Since two clients saw the same symptom with the same server at nearly
the same time, my first guess would be a server problem (bug).


--
Chuck Lever
chucklever@gmail.com



