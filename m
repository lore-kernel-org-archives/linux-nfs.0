Return-Path: <SRS0=29O7=R4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F295DC43381
	for <linux-nfs@archiver.kernel.org>; Mon, 25 Mar 2019 15:03:01 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CA56D2075C
	for <linux-nfs@archiver.kernel.org>; Mon, 25 Mar 2019 15:03:01 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729452AbfCYPDB (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 25 Mar 2019 11:03:01 -0400
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:40864 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1726217AbfCYPDA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Mar 2019 11:03:00 -0400
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2PF1DgX027477
        for <linux-nfs@vger.kernel.org>; Mon, 25 Mar 2019 11:02:59 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2reybuep8h-1
        (version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
        for <linux-nfs@vger.kernel.org>; Mon, 25 Mar 2019 11:02:58 -0400
Received: from localhost
        by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <linux-nfs@vger.kernel.org> from <zohar@linux.ibm.com>;
        Mon, 25 Mar 2019 15:02:13 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
        by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
        (version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
        Mon, 25 Mar 2019 15:02:10 -0000
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
        by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x2PF29ds42139752
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 25 Mar 2019 15:02:09 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
        by IMSVA (Postfix) with ESMTP id 27A9DA4060;
        Mon, 25 Mar 2019 15:02:09 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
        by IMSVA (Postfix) with ESMTP id 40334A405C;
        Mon, 25 Mar 2019 15:02:08 +0000 (GMT)
Received: from localhost.localdomain (unknown [9.80.109.48])
        by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTP;
        Mon, 25 Mar 2019 15:02:08 +0000 (GMT)
Subject: Re: [PATCH v2 3/5] NFSD: Remove ima_file_check call
From:   Mimi Zohar <zohar@linux.ibm.com>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     Bruce Fields <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-integrity@vger.kernel.org,
        "Serge E. Hallyn" <serge@hallyn.com>
Date:   Mon, 25 Mar 2019 11:01:57 -0400
In-Reply-To: <E51D17F4-5641-48D9-A2A2-56D13F44DF75@oracle.com>
References: <20190307151838.11306.94183.stgit@manet.1015granger.net>
         <20190307152854.11306.84006.stgit@manet.1015granger.net>
         <20190308211016.GB27011@fieldses.org>
         <ECE4FD20-840C-4047-9454-27BDF0A905EA@oracle.com>
         <20190308212310.GB28002@fieldses.org>
         <872F3DFD-E1A7-443E-B666-25C5931F0748@oracle.com>
         <1553027371.4899.116.camel@linux.ibm.com>
         <0E02D70A-A5E9-4B27-9922-521D5A0755A3@oracle.com>
         <1553168687.4899.396.camel@linux.ibm.com>
         <D2C155AD-7888-43CB-A25A-461FF474BDB7@oracle.com>
         <1553295305.5291.40.camel@linux.ibm.com>
         <E51D17F4-5641-48D9-A2A2-56D13F44DF75@oracle.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.20.5 (3.20.5-1.fc24) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19032515-0008-0000-0000-000002D15290
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19032515-0009-0000-0000-0000223D7B34
Message-Id: <1553526117.3929.32.camel@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-25_09:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=915 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903250112
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, 2019-03-25 at 10:24 -0400, Chuck Lever wrote:

> Auditing can be done by keeping the ima_file_check call site but
> ignoring its return code, for example.

Neither the "measure" or "audit" rules control the return code.  Only
an IMA "appraise" rule verifies a file's integrity, which could fail,
resulting in an error return code.

Different systems might have different requirements.  Having the IMA
hook here, allows IMA custom policies to be defined, based on the
specific system requirements.

In terms of performance, IMA calculates the file hash once, which can
then be used for measuring, appraising, and auditing.  Unless the file
changes, calculating the file hash is only done once.

> In any event, removing the ima_file_check call is not required for
> the prototype to be functional. I can drop this patch for now, but
> I encourage examination of how the NFS server measures and audits
> files when an actual IMA policy is in effect.

Thank you!

Mimi

