Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e8.ny.us.ibm.com ([32.97.182.138]:43786 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756252Ab3J1Wlm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Oct 2013 18:41:42 -0400
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <eshel@us.ibm.com>;
	Mon, 28 Oct 2013 18:41:41 -0400
Received: from b01cxnp23032.gho.pok.ibm.com (b01cxnp23032.gho.pok.ibm.com [9.57.198.27])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 778B8C90026
	for <linux-nfs@vger.kernel.org>; Mon, 28 Oct 2013 18:41:38 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by b01cxnp23032.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r9SMfdiR49479766
	for <linux-nfs@vger.kernel.org>; Mon, 28 Oct 2013 22:41:39 GMT
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r9SMfcx6027039
	for <linux-nfs@vger.kernel.org>; Mon, 28 Oct 2013 20:41:39 -0200
In-Reply-To: <OF9D091881.D4CDB064-ON88257C12.007629C1-88257C12.007B7AFE@us.ibm.com>
References: <1382920068.6932.46.camel@heisenberg.scientia.net>	<2E672741-FE4F-4287-8D00-B7634A71709E@netapp.com>
	<526E8562.3040809@redhat.com>	<1382976943.8774.10.camel@heisenberg.scientia.net>
	<FD29488A-348B-48BA-9B1D-4ACF997BC794@netapp.com>	<526EA65A.7010209@redhat.com> <20131028180838.GG31322@fieldses.org>
	<526EAD86.6090507@redhat.com>	<OFA4C7B613.86F16AC7-ON88257C12.006FE486-88257C12.0071EE79@us.ibm.com>
	<C2C70C2E-100E-40BD-A919-A4F649077059@netapp.com>	<20131028210247.GM31322@fieldses.org>
	<6AB20096-3993-47DD-AB58-2CD25F8A75D8@oracle.com>	<OF3A48E6D9.7BB93CB0-ON88257C12.0075527E-88257C12.0075F065@LocalDomain> <OF9D091881.D4CDB064-ON88257C12.007629C1-88257C12.007B7AFE@us.ibm.com>
To: Marc Eshel <eshel@us.ibm.com>
Cc: Mailing List Linux NFS <linux-nfs@vger.kernel.org>, nfsv4@ietf.org,
        nfsv4-bounces@ietf.org
MIME-Version: 1.0
Subject: XATTRs in NFS
From: Marc Eshel <eshel@us.ibm.com>
Message-ID: <OF7DBE5533.A67587D8-ON88257C12.007C1560-88257C12.007CA986@us.ibm.com>
Date: Mon, 28 Oct 2013 15:41:37 -0700
Content-Type: text/plain; charset="US-ASCII"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a clean start to discuss extended attributes over NFS in the 
mailing list first. 

1. What are the requirements and why? which applications are using them 
and how. 
2. Why are current named attributes in NFS not the right answer. 
3. What does the new protocol enhancements should look like? 

Thanks, Marc.

