Return-Path: <SRS0=fB6X=RY=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EBA64C10F00
	for <linux-nfs@archiver.kernel.org>; Thu, 21 Mar 2019 11:45:06 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BD1FD218FD
	for <linux-nfs@archiver.kernel.org>; Thu, 21 Mar 2019 11:45:06 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727883AbfCULpG (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 21 Mar 2019 07:45:06 -0400
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:59134 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1725985AbfCULpF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Mar 2019 07:45:05 -0400
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2LBcxmE064825
        for <linux-nfs@vger.kernel.org>; Thu, 21 Mar 2019 07:45:04 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2rc9f9sdyw-1
        (version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
        for <linux-nfs@vger.kernel.org>; Thu, 21 Mar 2019 07:45:03 -0400
Received: from localhost
        by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <linux-nfs@vger.kernel.org> from <zohar@linux.ibm.com>;
        Thu, 21 Mar 2019 11:44:56 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
        by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
        (version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
        Thu, 21 Mar 2019 11:44:54 -0000
Received: from d06av21.portsmouth.uk.ibm.com (d06av21.portsmouth.uk.ibm.com [9.149.105.232])
        by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x2LBixrO60883144
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Thu, 21 Mar 2019 11:44:59 GMT
Received: from d06av21.portsmouth.uk.ibm.com (unknown [127.0.0.1])
        by IMSVA (Postfix) with ESMTP id 0213552057;
        Thu, 21 Mar 2019 11:44:59 +0000 (GMT)
Received: from localhost.localdomain (unknown [9.80.93.235])
        by d06av21.portsmouth.uk.ibm.com (Postfix) with ESMTP id 495A75204F;
        Thu, 21 Mar 2019 11:44:58 +0000 (GMT)
Subject: Re: [PATCH v2 3/5] NFSD: Remove ima_file_check call
From:   Mimi Zohar <zohar@linux.ibm.com>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     Bruce Fields <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-integrity@vger.kernel.org,
        "Serge E. Hallyn" <serge@hallyn.com>
Date:   Thu, 21 Mar 2019 07:44:47 -0400
In-Reply-To: <0E02D70A-A5E9-4B27-9922-521D5A0755A3@oracle.com>
References: <20190307151838.11306.94183.stgit@manet.1015granger.net>
         <20190307152854.11306.84006.stgit@manet.1015granger.net>
         <20190308211016.GB27011@fieldses.org>
         <ECE4FD20-840C-4047-9454-27BDF0A905EA@oracle.com>
         <20190308212310.GB28002@fieldses.org>
         <872F3DFD-E1A7-443E-B666-25C5931F0748@oracle.com>
         <1553027371.4899.116.camel@linux.ibm.com>
         <0E02D70A-A5E9-4B27-9922-521D5A0755A3@oracle.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.20.5 (3.20.5-1.fc24) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19032111-0008-0000-0000-000002CFEC8E
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19032111-0009-0000-0000-0000223C07F7
Message-Id: <1553168687.4899.396.camel@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-21_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903210086
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, 2019-03-20 at 08:40 -0500, Chuck Lever wrote:
> 
> > On Mar 19, 2019, at 3:29 PM, Mimi Zohar <zohar@linux.ibm.com> wrote:
> > 
> > On Fri, 2019-03-08 at 16:29 -0500, Chuck Lever wrote:
> > 
> > Thanks Serge for bringing this thread to my attention.  Sorry for the
> > delay in responding ...
> > 
> >>> On Mar 8, 2019, at 4:23 PM, Bruce Fields <bfields@fieldses.org> wrote:
> >>> 
> >>> On Fri, Mar 08, 2019 at 04:11:06PM -0500, Chuck Lever wrote:
> >>>> 
> >>>> 
> >>>>> On Mar 8, 2019, at 4:10 PM, bfields@fieldses.org wrote:
> >>>>> 
> >>>>> On Thu, Mar 07, 2019 at 10:28:54AM -0500, Chuck Lever wrote:
> >>>>>> The NFS server needs to allow NFS clients to perform their own
> >>>>>> attestation and measurement.
> > 
> > Measurement and attestation is only one aspect.  The other aspect is
> > verifying the integrity of files.  Shouldn't the NFS server verify the
> > integrity of a file before allowing it to be served (eg. malware)?
> 
> Hi Mimi, thanks for the review.
> 
> Architecturally, the server is not using the file's data, it is
> merely part of the filesystem that stores it. But that said, there
> are several concrete reasons why I feel an NFS server should not be
> involved in measurement/attestation, but only with storing file
> content and IMA metadata.

"Remote attestation" is the process of verifying the measurement list
against the TPM PCRs, based on a TPM quote.  I think you meant
"measurement/appraisal".

> 
> 1. The broadest attack surface for a remote filesystem is modification
> of data in flight. Attestation of the file on the server is not going
> to defend against that attack, only attestation on the client will do
> that. Is there a good reason to pay the cost of double attestation?

Doesn't the server have a responsibility to provide files that have
not been unintentionally or maliciously altered?

> 2. It is possible (perhaps even likely) that the NFS server and a
> client of that server will have different IMA policies and even
> different file signing authorities.

That doesn't negate the due diligence on the server's part of
preventing the spread of malware.
> 
> A third, perhaps related, reason is that NFS can run on non-Linux NFS
> servers which would not have any attestation at all. An NFS client
> should not have to rely on the server for attestation, but should
> trust only its own measurement of each file, which would be done as
> late as possible before use.

The ima_file_check() hook can also audit the file, providing
additional forensic information (eg. the file hash).

Mimi

> 
> Lastly, the NFS protocol does not enable an NFS client to tell a
> server how the file is to be used. For example, the server's policy
> might block execution of an unverifiable file, but the server won't
> have any way of knowing how the client is going to use that file.
> The client might be opening the file to copy it or update its IMA
> metadata.
> 
> Speaking of protocol, there's no special error code that reports an
> integrity verification failure. The client just sees that the UID
> does not have access to the file. There's no way the user or client
> can do anything to clear this condition via NFS without IMA support.
> 
> If these reasons make sense, should I add them to the patch description?
> 

