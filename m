Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:28507 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751130AbaE2RHq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 May 2014 13:07:46 -0400
Message-ID: <53876938.7000704@oracle.com>
Date: Thu, 29 May 2014 10:07:04 -0700
From: Shirley Ma <shirley.ma@oracle.com>
MIME-Version: 1.0
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Jeff Becker <jeffrey.c.becker@nasa.gov>,
        "<yanb@mellanox.com>" <yanb@mellanox.com>, wendy.cheng@intel.com,
        "Coulter, Susan K" <skc@lanl.gov>,
        Rupert Dance <rsdance@soft-forge.com>,
        Doug Ledford <dledford@redhat.com>,
        Devesh Sharma <Devesh.Sharma@Emulex.Com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        Steve Wise <swise@opengridcomputing.com>,
        Steve Dickson <SteveD@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: NFSoRDMA developers bi-weekly meeting minutes (5/28)
References: <5387615E.20206@oracle.com>
In-Reply-To: <5387615E.20206@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Attendees:

Jeff Beck (NASA)
Yan Burman (Mellanox)
Wendy Cheng (Intel)
Susan Coulter (LANL)
Rupert Dance (Soft Forge)
Chuck Lever (Oracle)
Doug Ledford (RedHat)
Shirley Ma (Oracle)
Devesh Sharma (Emulex)
Anna Schumaker (Net App)
Steve Wise (OpenGridComputing, Chelsio)

Moderator:
Shirley Ma (Oracle)

NFSoRDMA developers bi-weekly meeting is to help organizing NFSoRDMA development and test effort from different resources to speed up NFSoRDMA upstream kernel work and NFSoRDMA diagnosing/debugging tools development. Hopefully the quality of NFSoRDMA upstream patches can be improved by being tested by a quorum of HW vendors.

Today's meeting notes:
1. OFED release update from Rupert Dance through email:

a. OFED 3.12 was released yesterday without any patch from Chuck's git tree, one of the reason these patches haven't upstream yet. There were a number of new bugs filed on NFSRDMA (2489 and 2490).
http://bugs.openfabrics.org/bugzilla/show_bug.cgi?id=2489
http://bugs.openfabrics.org/bugzilla/show_bug.cgi?id=2490

b. Jeff Becker has pulled all of the patches from Chuck's git tree and made backports in his local branch of OFED 3.12. He has begun testing and is seeing good results so far.

c. OFED next release will be OFED 3.12-1 and it will be including all these updates along with support for RHEL 7.0 and Intel's OFED MIC.

2. NFSoRDMA support with soft RoCE and Soft iWARP

There were some discussions regarding whether removing RPCRDMA_REGISTER support (one of Chuck's patchset) would impact any other components in the stack. So far soft RoCE hasn't been upstreamed yet.There was a broad consensus not to support out-of-tree providers unless an issue also affects in-tree providers. NFSoRDMA will follow kernel development policy, all work should be based upon upstream kernel. However Chuck Level will check Soft RoCE plan, Steve Wise will check soft iWARP plan to make sure nothing will be broken in both kernel and OFED release. 

3. Update on testing NFSoRDMA client patches:

Devesh Sharma, Doug Ledford, Chuck Lever, Steve Wise all have tested Chuck git tree (up to last weeks patchsets) on different platforms with various vendor's HCAs. The test showed the stack pretty reliable for both NFSv3 and NFSv4. However NFSv4.1 hit server crash. (NFSv4.1 hasn't support yet).

Steve Wise's test covers iWARP Chelsio
Devesh Sharma's test covers Emulex
Chuck Lever/Shirley Ma's test covers Mellanox
Doug Ledford's test covers various platforms and combination of HCAs (Interoperability test).
Jeff Beck's test covers OFED release (backport)
Rupert Dance's (IOL) team test covers various platforms and combination of HCAs as well.

The test coverage should be good enough for NFSoRDMA client patchsets to be merged to upstream by Anna and Trond.

Devesh is looking for performance benchmark tools. IOzone is recommended. Anna is going to send more performance tools.

A place to save test results as scratch sheets has been discussed so it will be easy to track the test history for any regressions. Anna will help to figure it out.

A couple of new bugs have been filed to track existing issues. Devesh had hit a bug in dbench test, which Steve Wise already worked on it.

https://bugzilla.linux-nfs.org/show_bug.cgi?id=255

Klemens Senn has reported a soft lockup in unloading kernel module. Shirley has tried to reproduce this problem with Linux server, Solaris client, it didn't hit any issue. So it's a problem between Linux client and server.

https://bugzilla.linux-nfs.org/show_bug.cgi?id=252


4. Steve shared his findings on some bug he has bee working on -- refactoring patchset.

5. Followups update from last week
a. Linux server maintenance is still in unresolved status.

b. NFSoRDMA debugging and diagnosis tools?
Yan has made some progress on NFSoRDMA wireshark dissector. Selecting connection is not as simple as TCP, Yan has tried to use QP number/RDMA establish status to build the connection. Chuck suggested to try RPC XID field.

c. NFSoRDMA virtualization validation:
Shirley has set up KVM guest with Mellanox Connect2 SRIOV. A panic occurred right away during mount, the panic is different with XEN domU guest.

Next meeting topics proposal:
1. Follow up the work has been discussed from this meeting.

2. Walk through some of the stories on pivotal, link is as below:
https://www.pivotaltracker.com/s/projects/958376

3. Invite some of the developers to discuss some of their requirements and features.

Meeting time: one hour discussion every other Wed (next meeting will be
on 6/11). A reminder will be sent out to both linux-nfs and linux-rdma
mailing list:

6/11/2014
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

Thanks everyone for joining the call and providing valuable inputs/work to the community to make NFSoRDMA better.

Shirley



Attendees:

Jeff Beck (NASA)
Yan Burman (Mellanox)
Wendy Cheng (Intel)
Susan Coulter (LANL)
Rupert Dance (Soft Forge)
Chuck Lever (Oracle)
Doug Ledford (RedHat)
Shirley Ma (Oracle)
Devesh Sharma (Emulex)
Anna Schumaker (Net App)
Steve Wise (OpenGridComputing, Chelsio)

Moderator:
Shirley Ma (Oracle)

NFSoRDMA developers bi-weekly meeting is to help organizing NFSoRDMA development and test effort from different resources to speed up NFSoRDMA upstream kernel work and NFSoRDMA diagnosing/debugging tools development. Hopefully the quality of NFSoRDMA upstream patches can be improved by being tested by a quorum of HW vendors.

Today's meeting notes:
1. OFED release update from Rupert Dance through email:

a. OFED 3.12 was released yesterday without any patch from Chuck's git tree, one of the reason these patches haven't upstream yet. There were a number of new bugs filed on NFSRDMA (2489 and 2490).
http://bugs.openfabrics.org/bugzilla/show_bug.cgi?id=2489
http://bugs.openfabrics.org/bugzilla/show_bug.cgi?id=2490

b. Jeff Becker has pulled all of the patches from Chuck's git tree and made backports in his local branch of OFED 3.12. He has begun testing and is seeing good results so far.

c. OFED next release will be OFED 3.12-1 and it will be including all these updates along with support for RHEL 7.0 and Intel's OFED MIC.

2. NFSoRDMA support with soft RoCE and Soft iWARP

There were some discussions regarding whether removing RPCRDMA_REGISTER support (one of Chuck's patchset) would impact any other components in the stack. So far soft RoCE hasn't been upstreamed yet.There was a broad consensus not to support out-of-tree providers unless an issue also affects in-tree providers. NFSoRDMA will follow kernel development policy, all work should be based upon upstream kernel. However Chuck Level will check Soft RoCE plan, Steve Wise will check soft iWARP plan to make sure nothing will be broken in both kernel and OFED release. 

3. Update on testing NFSoRDMA client patches:

Devesh Sharma, Doug Ledford, Chuck Lever, Steve Wise all have tested Chuck git tree (up to last weeks patchsets) on different platforms with various vendor's HCAs. The test showed the stack pretty reliable for both NFSv3 and NFSv4. However NFSv4.1 hit server crash. (NFSv4.1 hasn't support yet).

Steve Wise's test covers iWARP Chelsio
Devesh Sharma's test covers Emulex
Chuck Lever/Shirley Ma's test covers Mellanox
Doug Ledford's test covers various platforms and combination of HCAs (Interoperability test).
Jeff Beck's test covers OFED release (backport)
Rupert Dance's (IOL) team test covers various platforms and combination of HCAs as well.

The test coverage should be good enough for NFSoRDMA client patchsets to be merged to upstream by Anna and Trond.

Devesh is looking for performance benchmark tools. IOzone is recommended. Anna is going to send more performance tools.

A place to save test results as scratch sheets has been discussed so it will be easy to track the test history for any regressions. Anna will help to figure it out.

A couple of new bugs have been filed to track existing issues. Devesh had hit a bug in dbench test, which Steve Wise already worked on it.

https://bugzilla.linux-nfs.org/show_bug.cgi?id=255

Klemens Senn has reported a soft lockup in unloading kernel module. Shirley has tried to reproduce this problem with Linux server, Solaris client, it didn't hit any issue. So it's a problem between Linux client and server.

https://bugzilla.linux-nfs.org/show_bug.cgi?id=252


4. Steve shared his findings on some bug he has bee working on -- refactoring patchset.

5. Followups update from last week
a. Linux server maintenance is still in unresolved status.

b. NFSoRDMA debugging and diagnosis tools?
Yan has made some progress on NFSoRDMA wireshark dissector. Selecting connection is not as simple as TCP, Yan has tried to use QP number/RDMA establish status to build the connection. Chuck suggested to try RPC XID field.

c. NFSoRDMA virtualization validation:
Shirley has set up KVM guest with Mellanox Connect2 SRIOV. A panic occurred right away during mount, the panic is different with XEN domU guest.

Next meeting topics proposal:
1. Follow up the work has been discussed from this meeting.

2. Walk through some of the stories on pivotal, link is as below:
https://www.pivotaltracker.com/s/projects/958376

3. Invite some of the developers to discuss some of their requirements and features.

Meeting time: one hour discussion every other Wed (next meeting will be
on 6/11). A reminder will be sent out to both linux-nfs and linux-rdma
mailing list:

6/11/2014
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

Thanks everyone for joining the call and providing valuable inputs/work to the community to make NFSoRDMA better.

Shirley
