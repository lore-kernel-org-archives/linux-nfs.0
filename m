Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:42792 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755287AbcGEU5z convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Jul 2016 16:57:55 -0400
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u65KtDej036706
	for <linux-nfs@vger.kernel.org>; Tue, 5 Jul 2016 16:57:55 -0400
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com [32.97.110.151])
	by mx0a-001b2d01.pphosted.com with ESMTP id 23x9prg25n-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Tue, 05 Jul 2016 16:57:54 -0400
Received: from localhost
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <eshel@us.ibm.com>;
	Tue, 5 Jul 2016 14:57:53 -0600
Received: from b03cxnp07029.gho.boulder.ibm.com (b03cxnp07029.gho.boulder.ibm.com [9.17.130.16])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id DF4E419D8045
	for <linux-nfs@vger.kernel.org>; Tue,  5 Jul 2016 14:57:26 -0600 (MDT)
Received: from b03ledav004.gho.boulder.ibm.com (b03ledav004.gho.boulder.ibm.com [9.17.130.235])
	by b03cxnp07029.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u65KvmDp52101346
	for <linux-nfs@vger.kernel.org>; Tue, 5 Jul 2016 13:57:49 -0700
Received: from b03ledav004.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 7B2DE78013
	for <linux-nfs@vger.kernel.org>; Tue,  5 Jul 2016 14:57:49 -0600 (MDT)
Received: from d50lp02.ny.us.ibm.com (unknown [146.89.104.208])
	by b03ledav004.gho.boulder.ibm.com (Postfix) with ESMTPS id 448DA7803F
	for <linux-nfs@vger.kernel.org>; Tue,  5 Jul 2016 14:57:49 -0600 (MDT)
Received: from localhost
	by d50lp02.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <eshel@us.ibm.com>;
	Tue, 5 Jul 2016 16:57:48 -0400
Received: from localhost
	by smtp.notes.na.collabserv.com with smtp.notes.na.collabserv.com ESMTP
	for <linux-nfs@vger.kernel.org> from <eshel@us.ibm.com>;
	Tue, 5 Jul 2016 20:56:56 -0000
In-Reply-To: <47ebf941-2e1c-83fc-93e0-b4d70892dc2c@RedHat.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org, Tomer Perry <TOMP@il.ibm.com>,
        "Jeff Layton" <jlayton@poochiereds.net>
Subject: Re: HA NFS
From: "Marc Eshel" <eshel@us.ibm.com>
Date: Tue, 5 Jul 2016 13:56:54 -0700
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
 <OF839F4B82.C0113FD6-ON88257FE6.00828B44-88257FE6.008343CD@notes.na.collabserv.com>
 <47ebf941-2e1c-83fc-93e0-b4d70892dc2c@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Message-Id: <OF17228003.A726621C-ON88257FE7.0072521B-88257FE7.007311FA@notes.na.collabserv.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks for the pointer Steve, I am not sure how much of the changes 
considered RedHat and how much is Linux kernel changes so if another 
mailing list is more appropriate please let me know. I now see on RHEL7.0 
that /var/lib/nfs/nfsdcltrack/main.sqlite is updated as I open a file from 
an NFS client, but going to RHEL7.2 that file is created but not updated 
with a new client open. Did something change in this area between 7.0 and 
7.2 ?
Marc.



From:   Steve Dickson <SteveD@redhat.com>
To:     Marc Eshel/Almaden/IBM@IBMUS
Cc:     linux-nfs@vger.kernel.org, Tomer Perry <TOMP@il.ibm.com>
Date:   07/05/2016 08:08 AM
Subject:        Re: HA NFS





On 07/04/2016 07:53 PM, Marc Eshel wrote:
> Hi Steve,
> I did not pay attention for a while and now I see that since RHEL7.0 
there 
> a major changes in NFSv4 recovery for a signal machine and for cluster 
> file system. Is there any write up on the changes like the use of 
> /var/lib/nfs/nfsdcltrack/main.sqlite, I see it being used in 7.0 but not 

> in 7.2. Any information would be appreciated.

That file is still being used... but there were some changes.

In RHEL 7.2 this was added for bz 1234598
commit c41a3d0a17baa61a07d48d8536e99908d765de9b
Author: Jeff Layton <jlayton@primarydata.com>
Date:   Fri Sep 19 11:07:31 2014 -0400

    nfsdcltrack: fetch NFSDCLTRACK_GRACE_START out of environment


In RHEL 7.3 there will be this for bz 1285097
commit d479ad3adb0671c48d6fbf3e36bd52a31159c413
Author: Jeff Layton <jlayton@primarydata.com>
Date:   Fri Sep 19 11:03:45 2014 -0400

    nfsdcltrack: update schema to v2

I hope this helps... 

steved.





