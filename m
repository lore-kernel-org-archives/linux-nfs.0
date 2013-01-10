Return-Path: linux-nfs-owner@vger.kernel.org
Received: from phsmgmx12.partners.org ([155.52.251.71]:12476 "EHLO
	phsmgmx12.partners.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752427Ab3AJUWN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jan 2013 15:22:13 -0500
Date: Thu, 10 Jan 2013 15:12:33 -0500 (EST)
From: Paul Raines <raines@nmr.mgh.harvard.edu>
To: linux-nfs@vger.kernel.org
Subject: NFS failover works RHEL6->5 but fails RHEL5->6
Message-ID: <alpine.LRH.2.00.1301101446340.26983@gate.nmr.mgh.harvard.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


I have an IBM GPFS cluster of 8 servers on shared SAN running RHEL5.  They use 
GPFS's included Clustered NFS (CNFS) to load balance NFS to clients via 
round-robin DNS and autofs.  This has worked fine for 3 years.  Recently I 
upgraded one of the boxes to RHEL6.  Base GPFS works fine on it.  But CNFS 
does not.  My first issue was that once CNFS was running on the RHEL6 server, 
it refused all mounts with the error in the syslog of:

rpc.mountd[16482]: authenticated mount request from
   bourget.nmr.mgh.harvard.edu:626 for /gpfs/nsdg01/itgroup
   (/gpfs/nsdg01/itgroup)
rpc.mountd[16482]: internal: no supported addresses in nfs_client
rpc.mountd[16482]: getfh failed: Operation notpermitted

So I started a service ticket with IBM but got nowhere with them.
I eventually found this on the web about a bug in cltsetup()

http://comments.gmane.org/gmane.linux.nfs/41432

I applied this patch to the stock RHEL6 nfs-utils source and rebuilt
and the above problem went away.

The curious thing about this patch is I did not have the problem when running 
RHEL6 NFS outside of GPFS nor did IBM have the problem with CNFS on their test 
systems on RHEL6.  So it is a mystery what was triggering it for me.  I 
mention this only in case it has bearing on the current problem that has me 
stuck.

With CNFS running and allowing mounts on the RHEL6 box, I killed the box. 
Everything failed over fine to one of the old RHEL5 servers.  Clients that had 
mounted NFS shares from the RHEL6 box could still see them.  I then brought 
the RHEL6 box back up which retook the virtual IP assigned to it.  But then 
client mounts now failed with "Stale NFS file handle"

So essentially NFS failover from RHEL5 to the RHEL6 box of NFS fails (but 
works the other way). And before you ask, yes, the /etc/exports on all boxes 
are exactly the same and have the same "fsid=" assigned on all shares.

IBM does not see this problem on their test systems.  They have no idea
and are just having me do "shot in the dark" upgrades and downgrades
on various things.

I am hoping someone on this list knows what a "Stale NFS file handle"
means in this situation when it is not a FSID mismatch that might
point me in a direction of what could be going wrong.

In case it helps here is a tcpdump of the packets on the server when
the Stale NFS file handle error happens

15:08:04.543680 IP bourget.nmr.mgh.harvard.edu.12492987 > 
gpfstest.nmr.mgh.harvard.edu.nfs: 112 getattr fh 
Unknown/01000100978A0100000000000000000000000000000000000000000000000000
15:08:04.543721 IP gpfstest.nmr.mgh.harvard.edu.nfs > 
bourget.nmr.mgh.harvard.edu.12492987: reply ok 28 getattr ERROR: Stale NFS 
file handle
15:08:04.544494 IP bourget.nmr.mgh.harvard.edu.979 > 
gpfstest.nmr.mgh.harvard.edu.nfs: Flags [.], ack 1811398839, win 1460, options 
[nop,nop,TS val 2056226500 ecr 1989675411], length 0

Also, if I bring down the RHEL6 box, so the failover occurs again to one
of the RHEL5 boxes, the client mount starts working again.

---------------------------------------------------------------
Paul Raines                     http://help.nmr.mgh.harvard.edu
MGH/MIT/HMS Athinoula A. Martinos Center for Biomedical Imaging
149 (2301) 13th Street     Charlestown, MA 02129	    USA





The information in this e-mail is intended only for the person to whom it is
addressed. If you believe this e-mail was sent to you in error and the e-mail
contains patient information, please contact the Partners Compliance HelpLine at
http://www.partners.org/complianceline . If the e-mail was sent to you in error
but does not contain patient information, please contact the sender and properly
dispose of the e-mail.

