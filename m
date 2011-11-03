Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.81]:37902 "EHLO
	hackers.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752335Ab1KCVig (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Nov 2011 17:38:36 -0400
Date: Thu, 3 Nov 2011 17:38:33 -0400
From: Jim Rees <rees@umich.edu>
To: Lukas Razik <linux@razik.name>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [BUG?] Maybe NFS bug since 2.6.37 on SPARC64
Message-ID: <20111103213833.GA741@umich.edu>
References: <1320349396.90614.YahooMailNeo@web24707.mail.ird.yahoo.com>
 <1320353685.18396.119.camel@lade.trondhjem.org>
 <1320355087.59657.YahooMailNeo@web24703.mail.ird.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <1320355087.59657.YahooMailNeo@web24703.mail.ird.yahoo.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Lukas Razik wrote:

  The next thing is:
  Really all working kernels (<=2.6.36.4) first output
   Looking up port of RPC 100003/2 on 137.226.167.241
  then
   Looking up port of RPC 100005/1 on 137.226.167.241
  and then the mount is successful
   VFS: Mounted root (nfs filesystem) on device 0:15.
  
  So what about >=2.6.37?
  Why don't these kernels try other ports, too?
  Or why do the old kernels try more than one port?
  Why is there no output (even in the nfsdebug mode) that the kernel tries to connect to the RPC service?
  Is there a "easy" possibility to change port 100003 to 100005 in >=2.6.37?

Those are the rpc numbers.  The kernel is trying to find the port numbers
for those services.  100003 is nfs, 100005 is mount.  I guess at this point
I would use wireshark to find out what requests are actually being made and
responded to in both cases.  Are you sure portmap is working on the server
and not being blocked by a firewall?
