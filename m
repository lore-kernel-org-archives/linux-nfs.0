Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:19413 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751207AbbDPTA6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Apr 2015 15:00:58 -0400
Message-ID: <553006BF.6050306@oracle.com>
Date: Thu, 16 Apr 2015 12:00:15 -0700
From: Shirley Ma <shirley.ma@oracle.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>,
        Jeff Becker <jeffrey.c.becker@nasa.gov>,
        Steve Wise <swise@opengridcomputing.com>,
        Steve Dickson <SteveD@redhat.com>,
        "<Devesh.Sharma@emulex.com>" <Devesh.Sharma@emulex.com>,
        Rupert Dance <rsdance@soft-forge.com>,
        Doug Ledford <dledford@redhat.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        "<yanb@mellanox.com>" <yanb@mellanox.com>,
        "Coulter, Susan K" <skc@lanl.gov>, wendy.cheng@intel.com,
        Dominique Martinet <dominique.martinet@cea.fr>, sprabhu@redhat.com
CC: linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: NFSoRDMA bi-weekly developers meeting minutes (4/16/15)
References: <53BC2123.4070206@oracle.com> <54063CB7.6060503@oracle.com> <54C7D09D.3000600@oracle.com> <54C937BA.9020606@oracle.com> <552EE56E.5060705@oracle.com>
In-Reply-To: <552EE56E.5060705@oracle.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Attendees:


Jeff Becker (NASA)
Wendy Cheng (Intel)
Chuck Lever (Oracle)
Doug Ledford (RedHat)
Shirley Ma (Oracle)
Anna Schumaker (Net App)
Steve Wise (OpenGridComputing, Chelsio)

Today's meeting notes:

NFSoRDMA server support:
-----------------------
NFSoRDMA Server is still technology preview in RHEL 7.2, since customers are looking for Linux NFSoRDMA server support, there is possible to open NFSoRDMA server support in the future. Jeff from NASA has some plan to deploy Linux NFSoRDMA, Mellanox OFED stack release might not support it, move to upstream OFED 3.18 is an option. Their fabrics is InfiniBand.

NFSoRDMA test plan (Doug, Wendy, Chuck)
------------------
Doug talked about future NFSoRDMA test infrastructure in RedHat. He has completed SCSI disk drivers characterization, the BW is around 3.9GB/s, next is file system, then NFSoRDMA and storage RDMA. Performance work will be investigated in both HW and software stack to see where to optimize it. He is open to take inputs on which particular file system to test, people can give suggests on which file systems they are interested. Chuck suggested NFSoRDMA performance work should include tempfs test since persistent disk is too slow for NFSoRDMA transport layer performance evaluation. The fabrics is mixed with DDR, QDR and EDR.
  
Wendy also talked about the possibility NFSoRDMA test in Intel. Currently they don't include NFSoRDMA in SPECNFS test, she asked whether it's possible to include it. Chuck replied the test client doesn't support NFSoRDMA client. He will talk to the maintainer to see whether NFSoRDMA can be supported, but needs to good reason to add it. Intel's test set up is RHEL 7.1, if enables NFSoRDMA test, the kernel should move to 3.18.

NFS bake-a-thon planning: (Doug, Chuck)
-------------------------
Chuck and Doug talked about incoming bake-a-thon plan, Doug has a small IB test et up, he can bring it to test. Solaris requires particular HCAs to work. They will talk to SteveD about several different possibilities to make it work.

NFSoRDMA performance: (Shirley, Chuck, SteveW)
---------------------
