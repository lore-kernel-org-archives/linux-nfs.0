Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:61257 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965255Ab3DPWGx convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Apr 2013 18:06:53 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFS loop on 3.4.39
Date: Tue, 16 Apr 2013 22:06:51 +0000
Message-ID: <1366150010.27817.8.camel@leira.trondhjem.org>
References: <OF6F031A84.8897519B-ONC1257B4E.002D1BA3-C1257B4E.002DBED0@LocalDomain>
		 <OF83CD52DB.8DBE497B-ONC1257B4E.002F8695-C1257B4E.002FBBD0@LocalDomain>
	 <OF64305930.0F7881A0-ONC1257B4E.0030250F-C1257B4E.00306CEC@LocalDomain>
	 <OFA06D4153.317BAF9A-ONC1257B4F.002F597B-C1257B4F.003AC46C@transmode.se>
	 <1366126613.12556.18.camel@leira.trondhjem.org>
	 <OFB2555ACD.CF7424A9-ONC1257B4F.00613A5E-C1257B4F.006908CE@transmode.se>
In-Reply-To: <OFB2555ACD.CF7424A9-ONC1257B4F.00613A5E-C1257B4F.006908CE@transmode.se>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-04-16 at 21:07 +0200, Joakim Tjernlund wrote:
> "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote on 2013/04/16 
> 17:36:55:
> 
> > From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
> > To: Joakim Tjernlund <joakim.tjernlund@transmode.se>, 
> > Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
> > Date: 2013/04/16 17:37
> > Subject: Re: NFS loop on 3.4.39
> > 
> > On Tue, 2013-04-16 at 12:41 +0200, Joakim Tjernlund wrote:
> > > Here we go again, this time i happened while browsing the Boston news 
> on 
> > > www.dn.se
> > > Now gvfsd-metadata is turned off(not running at all) and I get:
> > > 10:28:44.616146 IP 192.168.201.44.nfs > 172.20.4.10.3671768838: reply 
> ok 
> > > 52 getattr ERROR: unk 10024
> > 
> > Part of the reason why you are getting no response to these posts is
> > that you are posting tcpdump-decoded data. Tcpdump still has no support
> > for NFSv4, and therefore completely garbles the output by trying to
> > interpret it as NFSv2/v3.
> > In general, if you are posting network traffic, please record it as
> > binary raw packet data (using the '-w' option on tcdump) so that we can
> > look at the full contents. Either include it as an attachment, or
> > provide us with details on how to download it from an http server.
> > 
> > Other information that is needed in order to make sense of NFS bug
> > reports includes:
> 
> Thank you Trond, I figured there was something missing but I didn't know 
> where to start but here goes:
> 
> > 
> > - client OS (non-linux) or kernel version (linux)
> Client OS Linux 3.4.39, x86
> 
> > - mount options on the client
> ~ # ypmatch jocke auto.home
> -fstype=nfs,soft devsrv:/mnt/home/jocke
> 
> > - server OS (non-linux) or kernel version (linux)
> Server OS Linux 3.4.39, amd64
> 
> > - type of exported filesystem on the server
> XFS
> 
> > - contents of /etc/exports on the server
> more /etc/exports
> # /etc/exports: NFS file systems being exported.  See exports(5).
> /mnt/home              *(rw,async,root_squash,no_subtree_check)
> /mnt/systemtest        *(rw,sync,root_squash,no_subtree_check)
> /mnt/TNM               *(rw,sync,root_squash,no_subtree_check)
> /tftproot              *(rw,async,root_squash,no_subtree_check)
> /mnt/images *(rw,async,no_root_squash,no_subtree_check,insecure)
> /rescue *(ro,async,no_root_squash,no_subtree_check,insecure)
> 
> /mnt/home is the one failing
> 
> > 
> > Please ensure that you always include those in your emails.
> 
> nfs.pcap: 
> http://ftp-us.transmode.se/get/?id=1bf2561ed2e7d4e379b2936319c82c25
> 
> nfs2.pcap: 
> http://ftp-us.transmode.se/get/?id=759c7645248a426720da8e9ba7074040
> 
> nfs3.pcap: 
> http://ftp-us.transmode.se/get/?id=051c6d771978b2407e15e96152bd6e66
> 
> nfs4.pcap: 
> http://ftp-us.transmode.se/get/?id=5dfab4da6cbbe400697bc1621b541c9f
> 
> nfs3.pcap is the gvsd-metadata problem one can find using google, doesn't 
> have to be a NFS problem
> The other 3 all come from surfing the www using firefox 17.0.3

The nfs2.pcap file and nfs4.pcap seem to show the server returning
NFS4ERR_OLD_STATEID, which usually means that the client has an
OPEN/CLOSE/LOCK or LOCKU... in flight and that while the server has
updated the stateid, the client has not yet received the reply. The
problem is that I see no sign of the OPEN/CLOSE/LOCK/LOCKU...

The nfs.pcap file is resending a load of LOCK requests that are
receiving NFS4ERR_BAD_STATEID replies. Normally, I'd expect the recovery
engine to kick in and try to recover the OPEN.

So when you do 'ps -efwww', on any of these clients, do you see a
process with a name containing the server IP address (192.168.201.44)?

Also, is there anything special in the log when you do 'dmesg -s 90000'?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
