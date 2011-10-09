Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga03.intel.com ([143.182.124.21]:61938 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750773Ab1JILvL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 9 Oct 2011 07:51:11 -0400
Date: Sun, 9 Oct 2011 15:25:41 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
To: Yuri Csapo <ycsapo@mines.edu>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFS performance
Message-ID: <20111009072541.GA14690@localhost>
References: <4E8F2C8D.7070201@mines.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E8F2C8D.7070201@mines.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Yuri,

On Fri, Oct 07, 2011 at 10:45:01AM -0600, Yuri Csapo wrote:
> Hi all,
> 
> We've been battling a strange performance problem with one of our NFS
> servers. At mostly irregular intervals, our users report extremely slow
> responses. Those who are command line-challenged say that their windows
> "gray out" for a few seconds and won't let them do anything. Those who
> use the command line more report things like simple commands like cat
> taking a few seconds to "start."
> 
> On the server, the only indication we can see that anything is wrong is
> %iowait climbing above 80% while the event is happening. Running iotop
> we can see that it's the several nfsd processes that are driving IO.
> Another thing we have noticed is that when the backup process (Symantec
> NetBackup) runs, %iowait pegs at 100% for the duration.

Are there heavy writes during the time?  If so, it's likely all nfsd
processes get stuck directly on IO or indirectly on some inode mutex.

This could be improved by the "async" export option on the server side,
however at the cost of losing data in server crash events.

Thanks,
Fengguang

> I know that normally this would mean disk bottlenecks, but look at the
> specs below and you will see why I find that hard to believe. We have
> tried a ton of different monitoring tools and we are trying to fiddle
> with parameters at the NFS, tcp, and iSCSI levels to see if we can
> figure this out, so far with not a lot of luck.
> 
> The server
> ----------
> 
> . VMware virtual machine
> . 2 GB RAM, which sounds small but we rarely ever see any swapping
> . 2 cores
> . Stock CentOS 6.0 (Final)
> 
> The host
> --------
> 
> . Dell PowerEdge M610 blade
> . 2 x quad-core 2.4 GHz Xeon (L5530)
> . 48 GB RAM
> . ESXi 4
> 
> The storage
> -----------
> 
> The VM itself, as well as its system volume, reside on a group of 4
> EquaLogic ps6000 with 16 x 15K SAS disks each, on RAID50. The system
> volume (sda) is a VMware vmdk.
> 
> The data volume (sdb) is an iSCSI volume that the VM connects directly
> to, on an EquaLogic ps6510 with 48 x 3Gb/s SATA disks on RAID50.
> 
> The clients
> -----------
> 
> . About 50 clients
> . Brand new Dell Optiplexes (not sure about model)
> . 8 GB RAM
> . 2 x quad-core Intel Core i7-2600 @ 3.4 GHz
> . Ubuntu 10.04 lucid lynx LTS
> 
> The network
> -----------
> 
> . The blade has 6 NICs in 3 bonded pairs, all Gb Ethernet. One pair is
> for regular networking, one for vMotion, and one for SAN iSCSI access.
> The particular VM has two virtual (VMXNET3) NICs, one for regular
> service and one for iSCSI access. The blade links to a Cisco 3750 2
> switch stack.
> 
> . The ps6000 SAN links to the same 3750 stack through 4 bonded pairs (8
> NICs) each.
> 
> . The 3750 uplinks to a Cisco 6509.
> 
> . The 6509 downlinks to a different 3750 stack in a different building,
> through fiber, where all workstations link.
> 
> . The 6509 also links to a 3750x with 2 links of Gb Ethernet. The 3750x
> links over a 10 GB Ethernet to the ps6510 SAN.
> 
> I will appreciate any idea or insight into finding this problem.
> 
> Thanks!
> 
> Yuri
> 


