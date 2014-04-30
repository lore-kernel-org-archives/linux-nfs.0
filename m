Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:43879 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759299AbaD3TQ5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Apr 2014 15:16:57 -0400
Message-ID: <53614C03.80606@oracle.com>
Date: Wed, 30 Apr 2014 12:16:19 -0700
From: Shirley Ma <shirley.ma@oracle.com>
MIME-Version: 1.0
To: Jeff Becker <jeffrey.c.becker@nasa.gov>,
        "<yanb@mellanox.com>" <yanb@mellanox.com>,
        "Cayton, Phil" <phil.cayton@intel.com>,
        "Coulter, Susan K" <skc@lanl.gov>,
        Chuck Lever <chuck.lever@oracle.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        "<Devesh.Sharma@emulex.com>" <Devesh.Sharma@emulex.com>,
        Steve Wise <swise@opengridcomputing.com>,
        Allen Andrews <Allen.Andrews@emulex.com>,
        Jeff Layton <jlayton@redhat.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org, trond.myklebust@primarydata.com,
        "<emossman@iol.unh.edu>" <emossman@iol.unh.edu>
Subject: NFSoRDMA developers bi-weekly meeting announcement (4/30)
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Attendees:
Jeff Beck (NASA)
Yan Burman (Mellanox)
Phil Cayton (Intel)
Susan Coulter (LANL)
Chuck Lever (Oracle)
Shirley Ma (Oracle)
Anna Schumaker (Net App)
Devesh Sharma (Emulex)
Steve Wise (OpenGridComputing, Chelsio)

Moderate:
Shirley Ma (Oracle)

4/30/2014 meeting summaries:
NFSoRDMA developers bi-weekly meeting is to help organizing NFSoRDMA 
development and test effort from different resources to speed up 
NFSoRDMA upstream kernel work and NFSoRDMA diagnosing/debugging tools 
development. Hopefully the quality of NFSoRDMA upstream patches can be 
improved by being tested by a quorum of HW vendors. The NFSoRDMA issues 
can be tracked and followed up in time.

Today's meeting covered:
1. NFSoRDMA test strategy and plan:
What NFS related software tools are available for functional and 
performance test?
Chuck has created a wiki page for NFSoRDMA test. The wiki page covers 
NFSoRDMA functionality, stress and performance test. Here is the link to 
the wiki:

http://wiki.linux-nfs.org/wiki/index.php/NfsRdmaClient/Home#Submitting_patches 


If you have any other test suggestions like scalability test, please 
send to Chuck Lever.

How are we going to organize continuous testing resources:
Each of us have our own lab with different configuration, thus we could 
have a better test coverage without purchasing/installing all vendors 
hardware.

2. Helping others on problem report and follow up:
How to get help from the communities?
Problems should be reported on both linux-nfs and linux-rdma mailing 
list. However some others found the problems they reported had been 
ignored in the past. In order to better tracking NFSoRDMA bug report, we 
have created NFSoRDMA linux-nfs.org bugzilla family, which will be 
mirrored to liux-nfs, linux-rdma mailing list. Here is the link to 
linux-nfs.org NFSoRDMA bugzilla:

https://bugzilla.linux-nfs.org/enter_bug.cgi?product=kernel

NFSoRDMA server component: svcrdma
NFSoRDMA client component: xprtrdma

Chuck Lever and Shirley Ma will help tracking issues on NFSoRDMA bugs. 
This isn't guaranteed the bugs being assigned and fixed. Chuck Lever and 
Shirley Ma will work on NFSoRDMA client side issues. But we still 
couldn't locate resources to support NFSoRDMA server. This is an 
outstanding issue.

3. Upstream NFSoRDMA status:
Anna Schumaker has created git tree to maintain all NFSoRDMA client 
stable patches. It will be easy for maintainer to pull patches to 
upstream. NFSoRDMA end users can use her git tree. Here is the link to 
Anna's NFSoRDMA client git tree:

git://git.linux-nfs.org/projects/anna/nfs-rdma.git

Chuck Lever's NFSoRDMA linux-nfs.org git tree is for developers only. 
All patches should be reviewed and tested before going to Anna's tree. 
Here is link to Chuck Lever's git tree, check out nfs-rdma-client branch.

git://git.linux-nfs.org/projects/cel/cel-2.6.git

4. NFSoRDMA debugging and diagnosis tools:
ibdump is a ConnectX sniffing tool, which can be used to monitor 
InfiniBand packets on the fabrics. wireshark is able to interpret these 
packets in IB but not NFSoRDMA layer. A dissector is needed for NFSoRDMA 
protocol. Yan Burman will look at how much work to create NFSoRDMA 
dissector for wireshark.

Chelsio is also able to replicate packets to other interface for 
wireshark to monitor. Steve Wise will help on finding how-to instruction.

Next meeting topics proposal:
1. Follow up the work has been discussed from this meeting.

2. Walk through some of the stories on pivotal, link is as below:
https://www.pivotaltracker.com/s/projects/958376

3. Invite some of the developers to discuss some of their requirements 
and features.

Meeting time: one hour discussion every other Wed (next meeting will be 
on 5/14). A reminder will be sent out to both linux-nfs and linux-rdma 
mailing list:

5/14/2014
@8:00am PST
@9:00am MST
@10:00am CST
@11:00am EST
@Bangalore @9:00pm
@Israel @6:00pm

Duration: 1 hour

Call-in number:
Israel: +972 37219638
Bangalore: +91 8039890080 (180030109800)
US: 8666824770,  408-7744073
Conference Code: 2308833
Passcode: 63767362 (it's NFSoRDMA, in case you couldn't remember)

Thanks everyone for joining the call and providing valuable inputs/work 
to the community to make NFSoRDMA better. Anyone who are interested in 
NFSoRDMA is welcome to join the incoming meetings on 5/14.

Shirley
