From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Error mounting FC8 NFS server with 2.6.31-rc3 NFSv4 client.
Date: Tue, 21 Jul 2009 08:15:27 -0400
Message-ID: <1248178527.5222.0.camel@heimdal.trondhjem.org>
References: <4A64EB1F.4000602@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:57775 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754590AbZGUMPc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Jul 2009 08:15:32 -0400
In-Reply-To: <4A64EB1F.4000602@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-07-20 at 15:09 -0700, Ben Greear wrote:
> I tried mounting an NFS server running FC8 (2.6.26.8-57.fc8 kernel)
> using a Fedora 11 system running an un-patched 2.6.31-rc3 64-bit kernel.
> 
> I am not sure at all that the FC8 system is set up to handle NFSv4 properly, but
> I was expecting some sort of useful error if that was the case.
> 
> Instead, I get this continually spewing to /var/log/messages:
> 
> Error: state manager failed on NFSv4 server 192.168.100.6 with error 2
> Error: state manager failed on NFSv4 server 192.168.100.6 with error 2
> Error: state manager failed on NFSv4 server 192.168.100.6 with error 2
> Error: state manager failed on NFSv4 server 192.168.100.6 with error 2
> ...
> 
> On the file-server, I see this:
> Jul 19 04:47:59 fs2 kernel: nfs4_cb: server 192.168.100.196 not responding, timed out
> Jul 19 04:49:29 fs2 kernel: nfs4_cb: server 192.168.100.196 not responding, timed out
> Jul 19 04:49:29 fs2 ntpd[2585]: kernel time sync status change 0001
> Jul 19 04:50:59 fs2 kernel: nfs4_cb: server 192.168.100.196 not responding, timed out
> 
> 
> I added some debug patches (on top of my other patches, including those to nfs)
> and got some debug info:
> 
> It seems that nfs4_init_clientid is returning -2, and establish_clid is returning
> -2.  This causes reclaim lease logic to fail, and that causes state manager to print
> out the error repeatedly.  -2 means ENOENT.
> 
> 
> As far as I can tell, the mount never completes, staying in D state and filling up
> logs (I deleted a 16GB /var/log/messages file a few minutes ago!)
> 
> The mount command I'm trying is:
> mount -t nfs4 192.168.100.6:/export/tmp /mnt/lf/nfs4-0
> 
> 
> My kernel config is found here:
> http://www.candelatech.com/oss/i7_config.txt
> 

What does /var/lib/nfs/v4recovery look like on the server?

Trond

