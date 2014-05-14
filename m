Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:35392 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750702AbaENS5b (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 May 2014 14:57:31 -0400
Message-ID: <5373BC85.3030804@oracle.com>
Date: Wed, 14 May 2014 11:57:09 -0700
From: Shirley Ma <shirley.ma@oracle.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>, "Coulter, Susan K" <skc@lanl.gov>,
        Allen Andrews <Allen.Andrews@Emulex.Com>,
        Devesh Sharma <Devesh.Sharma@Emulex.Com>,
        "<yanb@mellanox.com>" <yanb@mellanox.com>,
        Rupert Dance <rsdance@soft-forge.com>,
        Jeff Becker <jeffrey.c.becker@nasa.gov>,
        David Stevens <dls0904@gmail.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        "Cayton, Phil" <phil.cayton@intel.com>, wendy.cheng@intel.com,
        Doug Ledford <dledford@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma <linux-rdma@vger.kernel.org>
Subject: NFSoRDMA developers bi-weekly meeting summary (5/14)
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Attendees:
Allen Andrews (Emulex)
Jeff Beck (NASA)
Yan Burman (Mellanox)
Wendy Cheng (Intel)
Rupert Dance (Soft Forge)
Chuck Lever (Oracle)
Doug Ledford (RedHat)
Shirley Ma (Oracle)
Anna Schumaker (Net App)
Steve Wise (OpenGridComputing, Chelsio)

Moderator:
Shirley Ma (Oracle)

NFSoRDMA developers bi-weekly meeting is to help organizing NFSoRDMA 
development and test effort from different resources to speed up 
NFSoRDMA upstream kernel work and NFSoRDMA diagnosing/debugging tools 
development. Hopefully the quality of NFSoRDMA upstream patches can be 
improved by being tested by a quorum of HW vendors.

Today's meeting notes:
1. Flesh out the process for testing and reviewing upstream patch sets:

What kind of test cases to run?
The upstream patch sets are required to test and pass functional test 
suites. In long run, performance test suites will be required. The 
performance test suites will be added later. Link to NFSoRDMA test wiki:
http://wiki.linux-nfs.org/wiki/index.php/NfsRdmaClient/Home#Submitting_patches 


How would linux-nfs git tree help NFSoRDMA patch sets upstream to 
mainline kernel?
Steve Wise will create linux-nfs NFSoRDMA server git tree with the help 
from Anna Schumaker. Chuck Lever's client branch git tree includes all 
client patch sets to be tested. Anna Schumaker maintains all client 
patches to be pulled into upstream which have passed the test suites 
(Sign-off: Tested-by). Steve Wise will create a branch to include both 
client and server patch sets in case you use the same node for both 
client and server.

How these tests to be done?
Each developer has his/her own hardware to test before submitting the 
patch sets. IOL has a broad variety of hardware, Rupert Dance would 
check how they can help in additional to OFED stack test. The test build 
process will be defined later.

2. Identify a long term resource for maintaining the linux NFSoRDMA server

Oracle has allocated resource to support NFSoRDMA client. Linux 
community needs funds to support NFSoRDMA server. There are engineer 
resources but not the money. Any third parties are interested in 
supporting NFSoRDMA server?

3. Follow ups from last meeting:

NFSoRDMA debugging and diagnosis tools?
Yan has started to look at NFSoRDMA dissector. Chelsio packets can be 
monitored when turning on switch port mirroring.
Chuck has created linux-nfs bugzilla for NFSoRDMA: server component is 
"svcrdma", client component is "xprtrdma" . Here is the link for you to 
check/submit bugs
https://bugzilla.linux-nfs.org/

4. NFSoRDMA visualization validation:
Yan and Shirley are working on validating ConnectX SRIOV on both Xen and 
KVM. They hit couple issues which need further debugging.

Next meeting topics proposal:
1. Follow up the work has been discussed from this meeting.

2. Walk through some of the stories on pivotal, link is as below:
https://www.pivotaltracker.com/s/projects/958376

3. Invite some of the developers to discuss some of their requirements 
and features.

Meeting time: one hour discussion every other Wed (next meeting will be 
on 5/14). A reminder will be sent out to both linux-nfs and linux-rdma 
mailing list:

5/28/2014
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
to the community to make NFSoRDMA better.

Shirley
