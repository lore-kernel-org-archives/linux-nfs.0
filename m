From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfs4 client not surviving server reboot
Date: Thu, 04 Jun 2009 14:51:39 -0400
Message-ID: <1244141499.5203.62.camel@heimdal.trondhjem.org>
References: <1244138569.8469.26.camel@pc.interlinx.bc.ca>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: "Brian J. Murrell" <brian-SquOHqY54CVWr29BmMi2cA@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:52840 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750814AbZFDSvl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Jun 2009 14:51:41 -0400
In-Reply-To: <1244138569.8469.26.camel-lA68w17JHpfIgqYUaR6mlLDks+cytr/Z@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-06-04 at 14:02 -0400, Brian J. Murrell wrote:
> Hi all,
> 
> A couple of times now I have (unforunately) needed to reboot the NFS
> server here and my one NFS4 client is simply not recovering that
> incident and needs to be rebooted as well.
> 
> The particulars are:
> 
> NFS Server:
> -----------
> Ubuntu Hardy running kernel 2.6.24-23-generic
> 
> NFS Client:
> -----------
> Ubuntu Jaunty running kernel 2.6.27-12-generic
> 
> The filesystems mounted are:
> 
> # grep linux: /proc/mounts
> linux:/home/share /autohome/share nfs4 rw,vers=4,rsize=8192,wsize=8192,namlen=255,hard,nointr,proto=tcp,timeo=600,retrans=2,sec=krb5,clientaddr=10.75.22.1,addr=10.75.22.3 0 0
> linux:/usr/local /usr/local nfs4 rw,vers=4,rsize=32768,wsize=32768,namlen=255,hard,nointr,proto=tcp,timeo=600,retrans=2,sec=krb5,clientaddr=10.75.22.1,addr=10.75.22.3 0 0
> linux:/mnt/data /data nfs4 rw,vers=4,rsize=32768,wsize=32768,namlen=255,hard,nointr,proto=tcp,timeo=600,retrans=2,sec=krb5,clientaddr=10.75.22.1,addr=10.75.22.3 0 0
> linux:/mnt/mp3 /mnt/mp3 nfs4 rw,vers=4,rsize=32768,wsize=32768,namlen=255,hard,nointr,proto=tcp,timeo=600,retrans=2,sec=krb5,clientaddr=10.75.22.1,addr=10.75.22.3 0 0
> 
> I don't really know where to even start trying to figure this one out.
> Ideas?

A dumpo of any relevant syslog entries would help, as would a packet
trace of the traffic between client and server (e.g. 'tcpdump -s 90000
-w /tmp/dump.out host <myserver> and port 2049'.

Trond

