Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46639 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754503Ab2EHMqD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 May 2012 08:46:03 -0400
Date: Tue, 8 May 2012 08:45:59 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Daniel Pocock <daniel@pocock.com.au>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: extremely slow nfs when sync enabled
Message-ID: <20120508124559.GA15448@fieldses.org>
References: <4FA5E950.5080304@pocock.com.au>
 <1336328594.2593.14.camel@lade.trondhjem.org>
 <4FA6EBD4.7040308@pocock.com.au>
 <1336340993.2600.11.camel@lade.trondhjem.org>
 <4FA6F75E.6090300@pocock.com.au>
 <1336344160.2600.30.camel@lade.trondhjem.org>
 <4FA793AB.70107@pocock.com.au>
 <4FA7D54E.9080309@pocock.com.au>
 <20120507171759.GA10137@fieldses.org>
 <4FA90C63.7000505@pocock.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FA90C63.7000505@pocock.com.au>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 08, 2012 at 12:06:59PM +0000, Daniel Pocock wrote:
> 
> 
> On 07/05/12 17:18, J. Bruce Fields wrote:
> > How many file creates per second?
> > 
> 
> I ran:
> nfsstat -s -o all -l -Z5
> and during the test (unpacking the tarball), I see numbers like these
> every 5 seconds for about 2 minutes:
> 
> nfs v3 server        total:      319
> ------------- ------------- --------
> nfs v3 server      getattr:        1
> nfs v3 server      setattr:      126
> nfs v3 server       access:        6
> nfs v3 server        write:       61
> nfs v3 server       create:       61
> nfs v3 server        mkdir:        3
> nfs v3 server       commit:       61

OK, so it's probably creating about 60 new files, each requiring a
create, write, commit, and two setattrs?

Each of those operations is synchronous, so probably has to wait for at
least one disk seek.  About 300 such operations every 5 seconds is about
60 per second, or about 16ms each.  That doesn't sound so far off.

(I wonder why it needs two setattrs?)

> I decided to expand the scope of my testing too, I want to rule out the
> possibility that my HP Microserver with onboard SATA is the culprit.  I
> set up two other NFS servers (all Debian 6, kernel 2.6.38):
> 
> HP Z800 Xeon workstation
> Intel Corporation 82801 SATA RAID Controller (operating as AHCI)
> VB0250EAVER (250GB 7200rpm)
> 
> Lenovo Thinkpad X220
> Intel Corporation Cougar Point 6 port SATA AHCI Controller (rev 04)
> SSDSA2BW160G3L  (160GB SSD)
> 
> Both the Z800 and X220 run as NFSv3 servers
> Each one has a fresh 10GB logical volume formatted ext4,
> mount options: barrier=1,data=ordered
> write cache (hdparm -W 1): enabled
> 
> Results:
> NFS client: X220
> NFS server: Z800 (regular disk)
> iostat reports about 1,000kbytes/sec when unpacking the tarball
> This is just as slow as the original NFS server

Again, reporting kbytes/second alone isn't useful--data throughput isn't
interesting for a workload like unpacking a tarball with a lot of small
files.  The limiting factor is the synchronous operations.

> NFS client: Z800
> NFS server: X220 (SSD disk)
> iostat reports about 22,000kbytes/sec when unpacking the tarball
> 
> It seems that buying a pair of SSDs for my HP MicroServer will let me
> use NFS `sync' and enjoy healthy performance - 20x faster.

And an SSD has much lower write latency, so this isn't surprising.

> However, is there really no other way to get more speed out of NFS when
> using the `sync' option?

I've heard reports of people being able to get better performance on
this kind of workload by using an external journal on an SSD.

(Last I tried this--with a machine at home, using (if I remember
correctly) ext4 on software raid with the journal on an intel x25-m, I
wasn't able to get any improvement.  I didn't try to figure out why.)

--b.
