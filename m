Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:51413 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751487AbcF3Vr0 convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Jun 2016 17:47:26 -0400
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u5ULhiBs054520
	for <linux-nfs@vger.kernel.org>; Thu, 30 Jun 2016 17:46:29 -0400
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
	by mx0a-001b2d01.pphosted.com with ESMTP id 23w62eun26-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Thu, 30 Jun 2016 17:46:28 -0400
Received: from localhost
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <eshel@us.ibm.com>;
	Thu, 30 Jun 2016 15:46:28 -0600
Received: from b03cxnp08027.gho.boulder.ibm.com (b03cxnp08027.gho.boulder.ibm.com [9.17.130.19])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id D3E6B3E4004F
	for <linux-nfs@vger.kernel.org>; Thu, 30 Jun 2016 15:46:25 -0600 (MDT)
Received: from b03ledav003.gho.boulder.ibm.com (b03ledav003.gho.boulder.ibm.com [9.17.130.234])
	by b03cxnp08027.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u5ULkPPN54919366
	for <linux-nfs@vger.kernel.org>; Thu, 30 Jun 2016 14:46:25 -0700
Received: from b03ledav003.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id B14D86A03C
	for <linux-nfs@vger.kernel.org>; Thu, 30 Jun 2016 15:46:25 -0600 (MDT)
Received: from d50lp31.co.us.ibm.com (unknown [9.17.249.32])
	by b03ledav003.gho.boulder.ibm.com (Postfix) with ESMTPS id 9C1DB6A041
	for <linux-nfs@vger.kernel.org>; Thu, 30 Jun 2016 15:46:25 -0600 (MDT)
Received: from localhost
	by d50lp31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <eshel@us.ibm.com>;
	Thu, 30 Jun 2016 15:46:25 -0600
Received: from localhost
	by smtp.notes.na.collabserv.com with smtp.notes.na.collabserv.com ESMTP
	for <linux-nfs@vger.kernel.org> from <eshel@us.ibm.com>;
	Thu, 30 Jun 2016 21:46:22 -0000
In-Reply-To: <1465939516-44769-1-git-send-email-trond.myklebust@primarydata.com>
To: "Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: grace period
From: "Marc Eshel" <eshel@us.ibm.com>
Date: Thu, 30 Jun 2016 14:46:19 -0700
References: <1465939516-44769-1-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Message-Id: <OF44E4DD0C.FF5B6C3E-ON88257FE2.00771383-88257FE2.007798E3@notes.na.collabserv.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce,
I see that setting the number of nfsd threads to 0 (echo 0 > 
/proc/fs/nfsd/threads) is not releasing the locks and putting the server 
in grace mode. What is the best way to go into grace period, in new 
version of the kernel, without restarting the nfs server?
Thanks, Marc.

