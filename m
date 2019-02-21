Return-Path: <SRS0=V3X6=Q4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9F4B3C43381
	for <linux-nfs@archiver.kernel.org>; Thu, 21 Feb 2019 15:51:55 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6C7DB20823
	for <linux-nfs@archiver.kernel.org>; Thu, 21 Feb 2019 15:51:55 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728324AbfBUPvy (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 21 Feb 2019 10:51:54 -0500
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:52242 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1728293AbfBUPvy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Feb 2019 10:51:54 -0500
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1LFnD8Q088249
        for <linux-nfs@vger.kernel.org>; Thu, 21 Feb 2019 10:51:53 -0500
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2qsw3ceeu7-1
        (version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
        for <linux-nfs@vger.kernel.org>; Thu, 21 Feb 2019 10:51:53 -0500
Received: from localhost
        by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <linux-nfs@vger.kernel.org> from <zohar@linux.ibm.com>;
        Thu, 21 Feb 2019 15:51:50 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
        by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
        (version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
        Thu, 21 Feb 2019 15:51:48 -0000
Received: from d06av24.portsmouth.uk.ibm.com (mk.ibm.com [9.149.105.60])
        by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1LFpl5R57475200
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
        Thu, 21 Feb 2019 15:51:47 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
        by IMSVA (Postfix) with ESMTP id 355FA4204B;
        Thu, 21 Feb 2019 15:51:47 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
        by IMSVA (Postfix) with ESMTP id 6AF784203F;
        Thu, 21 Feb 2019 15:51:46 +0000 (GMT)
Received: from localhost.localdomain (unknown [9.80.92.188])
        by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTP;
        Thu, 21 Feb 2019 15:51:46 +0000 (GMT)
Subject: Re: [PATCH RFC 0/4] IMA on NFS prototype
From:   Mimi Zohar <zohar@linux.ibm.com>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-integrity@vger.kernel.org,
        Allison Henderson <allison.henderson@oracle.com>,
        Dmitry Kasatkin <dmitry.kasatkin@gmail.com>
Date:   Thu, 21 Feb 2019 10:51:35 -0500
In-Reply-To: <71608AB6-ED45-43BA-A520-0DC2DA7D1C44@oracle.com>
References: <20190214203336.6469.34750.stgit@manet.1015granger.net>
         <1550623002.17768.10.camel@linux.ibm.com>
         <ABC54315-2F2B-4FA7-98A8-28A3FC2092DB@oracle.com>
         <1550665596.17768.32.camel@linux.ibm.com>
         <71608AB6-ED45-43BA-A520-0DC2DA7D1C44@oracle.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.20.5 (3.20.5-1.fc24) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19022115-4275-0000-0000-000003124E32
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19022115-4276-0000-0000-0000382082CC
Message-Id: <1550764295.17768.108.camel@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-21_09:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902210115
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, 2019-02-21 at 09:49 -0500, Chuck Lever wrote:
> 
> > On Feb 20, 2019, at 7:26 AM, Mimi Zohar <zohar@linux.ibm.com> wrote:
> > 
> > On Tue, 2019-02-19 at 22:51 -0500, Chuck Lever wrote:
> >>> On Feb 19, 2019, at 7:36 PM, Mimi Zohar <zohar@linux.ibm.com> wrote:
> >>> 
> >>> Hi Chuck,
> >>> 
> >>>> EVM is not supported in this prototype. NFS does not support several
> >>>> of the xattrs that are protected by EVM: SMACK64, Posix ACLs, and
> >>>> Linux file capabilities are not supported, which makes EVM more
> >>>> difficult to support on NFS mounts.
> >>> 
> >>> There's no requirement for all of these xattrs to exist.  If an xattr
> >>> does exist, then it is included in the security.evm hmac/signature.
> >> 
> >> Understood. The issue is that if they exist on a file residing on an NFS server,
> >> such xattrs would not be visible to clients. My understanding is that then EVM
> >> verification would fail on such files on NFS clients.
> >> 
> >> We could possibly make EVM work in limited scenarios until such time that
> >> the NFS protocol can make those xattrs available to NFS clients. I hope that
> >> having only security.ima is useful at least for experimenting and maybe more.
> >> 
> >> However, if folks think having security.evm also is needed, that is straight-
> >> forward... just saying that there are currently other limits in NFS that make a
> >> full EVM implementation problematic.
> > 
> > Thank you for the explanation.  Yes, I think there is a benefit of
> > having a file signature, without EVM.
> 
> It's been pointed out to me that a malicious actor inserted between
> an NFS server and an NFS client can concurrently substitute the IMA
> signature and a file's content with that of another file on the same
> NFS share.
> 
> This could be used to substitute /etc/group for /etc/passwd, for
> example. Both files are unchanged and have verifiable IMA signatures.
> The /etc/group file contains a passwd-like entry for root in it, but
> without a password field. That would allow the actor to gain root
> access on the NFS client.
> 
> NFS can mitigate this substitution by using Kerberos 5 integrity to
> protect wire traffic from tampering. However, a malicious NFS server
> could also perform this substitution, and krb5i would not be able to
> detect it.
> 
> I'm wondering if there's a mechanism within IMA's toolset to detect
> such a substitution on an NFS client.

This problem isn't limited to NFS, but is a general problem.  The file
name is part of the directory information, which would need to be
protected all the way up to root. (Dmitry's directory patches protects
one level of the directory tree.)

At last years LSF/MM, Allison Henderson gave a talk titled "XFS parent
pointers" - https://lwn.net/Articles/753480/.  After Allison's talk,
instead of protecting the entire filesystem directory hierarchy, Boaz
Harrosh suggested including the XFS parent pointers' pathname, stored
as an xattr, in the set of EVM protected xattrs.

Mimi

