Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:30183 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751823Ab1F3PgO convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jun 2011 11:36:14 -0400
Subject: Re: [nfsv4]nfs client bug
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Cc: Andy Adamson <andros@netapp.com>, quanli gui <gqlxj1987@gmail.com>,
        Benny Halevy <bhalevy@tonian.com>, linux-nfs@vger.kernel.org,
        "Mueller, Brian" <bmueller@panasas.com>
Date: Thu, 30 Jun 2011 11:35:57 -0400
In-Reply-To: <4E0C9284.5000804@panasas.com>
References: <BANLkTi=xcQseTx8BTWEzg-1DO=ayJuMLrw@mail.gmail.com>
		 <4E0B52BB.8090003@tonian.com>
		 <BANLkTinxF+obzedP+xupMCDZcgRTFDsQMg@mail.gmail.com>
		 <4CC6F947-FE93-47E4-9FD9-C0EB4D8033A6@netapp.com>
	 <1309443867.9544.59.camel@lade.trondhjem.org>
	 <4E0C9284.5000804@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1309448157.9544.88.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-06-30 at 18:13 +0300, Benny Halevy wrote: 
> On 2011-06-30 17:24, Trond Myklebust wrote:
> > On Thu, 2011-06-30 at 09:36 -0400, Andy Adamson wrote: 
> >> On Jun 29, 2011, at 10:32 PM, quanli gui wrote:
> >>
> >>> When I use the iperf tools for one client to 4 ds, the network
> >>> throughput is 890MB/S. It reflect that it is indeed 10GE non-blocking.
> >>>
> >>> a. about block size, I use bs=1M when I use dd
> >>> b. we indeed use the tcp (doesn't the nfsv4 use the tcp defaultly?)
> >>> c. the jumbo frames is what? how set mtu automatically?
> >>>
> >>> Brian, do you have some more tips?
> >>
> >> 1) Set the mtu on both the client and the server 10G interface. Sometimes 9000 is too high. My setup uses 8000.
> >> To set MTU on interface eth0.
> >>
> >> % ifconfig eth0 mtu 9000
> >>
> >> iperf will report the MTU of the full path between client and server - use it to verify the MTU of the connection.
> >>
> >> 2) Increase the # of rpc_slots on the client.
> >> % echo 128 > /proc/sys/sunrpc/tcp_slot_table_entries
> >>
> >> 3) Increase the # of server threads
> >>
> >> % echo 128 > /proc/fs/nfsd/threads
> >> % service nfs restart
> >>
> >> 4) Ensure the TCP buffers on both the client and the server are large enough for the TCP window.
> >> Calculate the required buffer size by pinging the server from the client with the MTU packet size and multiply the round trip time by the interface capacity
> >>
> >> % ping -s 9000 server  - say 108 ms average
> >>
> >> 10Gbits/sec = 1,250,000,000 Bytes/sec * .108 sec = 135,000,000 bytes
> >>
> >> Use this number to set the following: 
> >> sysctl -w net.core.rmem_max = 135000000
> >> sysctl -w net.core.wmem_max 135000000
> >> sysctl -w "net.ipv4.tcp_rmem <first number unchaged> <second unchanged> 135000000"
> >> sysctl net.ipv4.tcp_wmem  <first number unchaged> <second unchanged> 135000000"
> >>
> >> 5) mount with rsize=131072,wsize=131072
> > 
> > 6) Note that NFS always guarantees that the file is _on_disk_ after
> > close(), so if you are using 'dd' to test, then you should be using the
> > 'conv=fsync' flag (i.e 'dd if=/dev/zero of=test count=20k conv=fsync')
> > in order to obtain a fair comparison between the NFS and local disk
> > performance. Otherwise, you are comparing NFS and local _pagecache_
> > performance.
> 
> FWIW, modern versions of gnu dd (not sure exactly which version changed that)
> calculate and report throughput after close()ing the output file.

...but not after syncing it unless you explicitly request that.

On most (all?) local filesystems, close() does not imply fsync().

Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

