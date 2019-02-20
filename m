Return-Path: <SRS0=q2Lh=Q3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A3DDC10F01
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 12:26:54 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7593C2147C
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 12:26:54 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726414AbfBTM0x (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 20 Feb 2019 07:26:53 -0500
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:48582 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1727409AbfBTM0x (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Feb 2019 07:26:53 -0500
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1KCOjEt042507
        for <linux-nfs@vger.kernel.org>; Wed, 20 Feb 2019 07:26:52 -0500
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2qs6eus8pe-1
        (version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
        for <linux-nfs@vger.kernel.org>; Wed, 20 Feb 2019 07:26:51 -0500
Received: from localhost
        by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <linux-nfs@vger.kernel.org> from <zohar@linux.ibm.com>;
        Wed, 20 Feb 2019 12:26:50 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
        by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
        (version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
        Wed, 20 Feb 2019 12:26:48 -0000
Received: from d06av21.portsmouth.uk.ibm.com (d06av21.portsmouth.uk.ibm.com [9.149.105.232])
        by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1KCQloU26869944
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Wed, 20 Feb 2019 12:26:48 GMT
Received: from d06av21.portsmouth.uk.ibm.com (unknown [127.0.0.1])
        by IMSVA (Postfix) with ESMTP id D284352050;
        Wed, 20 Feb 2019 12:26:47 +0000 (GMT)
Received: from localhost.localdomain (unknown [9.80.107.132])
        by d06av21.portsmouth.uk.ibm.com (Postfix) with ESMTP id 508A752052;
        Wed, 20 Feb 2019 12:26:47 +0000 (GMT)
Subject: Re: [PATCH RFC 0/4] IMA on NFS prototype
From:   Mimi Zohar <zohar@linux.ibm.com>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-nfs@vger.kernel.org, linux-integrity@vger.kernel.org
Date:   Wed, 20 Feb 2019 07:26:36 -0500
In-Reply-To: <ABC54315-2F2B-4FA7-98A8-28A3FC2092DB@oracle.com>
References: <20190214203336.6469.34750.stgit@manet.1015granger.net>
         <1550623002.17768.10.camel@linux.ibm.com>
         <ABC54315-2F2B-4FA7-98A8-28A3FC2092DB@oracle.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.20.5 (3.20.5-1.fc24) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19022012-0020-0000-0000-000003190B2C
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19022012-0021-0000-0000-0000216A5669
Message-Id: <1550665596.17768.32.camel@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-20_11:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902200090
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, 2019-02-19 at 22:51 -0500, Chuck Lever wrote:
> > On Feb 19, 2019, at 7:36 PM, Mimi Zohar <zohar@linux.ibm.com> wrote:
> > 
> > Hi Chuck,
> > 
> >> EVM is not supported in this prototype. NFS does not support several
> >> of the xattrs that are protected by EVM: SMACK64, Posix ACLs, and
> >> Linux file capabilities are not supported, which makes EVM more
> >> difficult to support on NFS mounts.
> > 
> > There's no requirement for all of these xattrs to exist.  If an xattr
> > does exist, then it is included in the security.evm hmac/signature.
> 
> Understood. The issue is that if they exist on a file residing on an NFS server,
> such xattrs would not be visible to clients. My understanding is that then EVM
> verification would fail on such files on NFS clients.
> 
> We could possibly make EVM work in limited scenarios until such time that
> the NFS protocol can make those xattrs available to NFS clients. I hope that
> having only security.ima is useful at least for experimenting and maybe more.
> 
> However, if folks think having security.evm also is needed, that is straight-
> forward... just saying that there are currently other limits in NFS that make a
> full EVM implementation problematic.

Thank you for the explanation.  Yes, I think there is a benefit of
having a file signature, without EVM.

Mimi

