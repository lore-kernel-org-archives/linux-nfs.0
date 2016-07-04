Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:57650 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752420AbcGDXx4 convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Jul 2016 19:53:56 -0400
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u64NnIiq079353
	for <linux-nfs@vger.kernel.org>; Mon, 4 Jul 2016 19:53:55 -0400
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com [32.97.110.153])
	by mx0a-001b2d01.pphosted.com with ESMTP id 23x8wvn4y0-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Mon, 04 Jul 2016 19:53:55 -0400
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <eshel@us.ibm.com>;
	Mon, 4 Jul 2016 17:53:54 -0600
Received: from b03cxnp08026.gho.boulder.ibm.com (b03cxnp08026.gho.boulder.ibm.com [9.17.130.18])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 6EB431FF001E
	for <linux-nfs@vger.kernel.org>; Mon,  4 Jul 2016 17:53:36 -0600 (MDT)
Received: from b03ledav004.gho.boulder.ibm.com (b03ledav004.gho.boulder.ibm.com [9.17.130.235])
	by b03cxnp08026.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u64NrrPx47120582
	for <linux-nfs@vger.kernel.org>; Mon, 4 Jul 2016 16:53:53 -0700
Received: from b03ledav004.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id DD4F978013
	for <linux-nfs@vger.kernel.org>; Mon,  4 Jul 2016 17:53:52 -0600 (MDT)
Received: from e39.co.us.ibm.com (unknown [9.17.249.49])
	by b03ledav004.gho.boulder.ibm.com (Postfix) with ESMTPS id C760278015
	for <linux-nfs@vger.kernel.org>; Mon,  4 Jul 2016 17:53:52 -0600 (MDT)
Received: from localhost
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <eshel@us.ibm.com>;
	Mon, 4 Jul 2016 17:53:52 -0600
Received: from /spool/local
	by smtp.notes.na.collabserv.com with smtp.notes.na.collabserv.com ESMTP
	for <linux-nfs@vger.kernel.org> from <eshel@us.ibm.com>;
	Mon, 4 Jul 2016 23:53:49 -0000
In-Reply-To: <OFC1237E53.3CFCA8E8-ON88257FE5.001D3182-88257FE5.001E3A5B@LocalDomain>
To: "Steve Dickson" <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org, Tomer Perry <TOMP@il.ibm.com>
Subject: HA NFS
From: "Marc Eshel" <eshel@us.ibm.com>
Date: Mon, 4 Jul 2016 16:53:46 -0700
References: <1465939516-44769-1-git-send-email-trond.myklebust@primarydata.com>
 <OF44E4DD0C.FF5B6C3E-ON88257FE2.00771383-88257FE2.007798E3@notes.na.collabserv.com>
 <20160701160857.GB20327@fieldses.org>
 <OF82A5FFDC.3CCEBF40-ON88257FE3.0059C174-88257FE3.00604E03@notes.na.collabserv.com>
 <20160701200742.GA24269@fieldses.org>
 <OF5D486F02.62CECB7B-ON88257FE3.0071DBE5-88257FE3.00722388@notes.na.collabserv.com>
 <20160701210151.GE24269@fieldses.org>
 <OF79A36FEE.749D5EF5-ON88257FE3.007C9721-88257FE3.007CC2B1@notes.na.collabserv.com>
 <20160702005820.GA27063@fieldses.org>
 <OFC1237E53.3CFCA8E8-ON88257FE5.001D3182-88257FE5.001E3A5B@LocalDomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Message-Id: <OF839F4B82.C0113FD6-ON88257FE6.00828B44-88257FE6.008343CD@notes.na.collabserv.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve,
I did not pay attention for a while and now I see that since RHEL7.0 there 
a major changes in NFSv4 recovery for a signal machine and for cluster 
file system. Is there any write up on the changes like the use of 
/var/lib/nfs/nfsdcltrack/main.sqlite, I see it being used in 7.0 but not 
in 7.2. Any information would be appreciated.
Thanks, Marc. 


