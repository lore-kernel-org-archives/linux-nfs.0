Return-Path: <SRS0=azWf=RW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C6F11C43381
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Mar 2019 20:29:41 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 99E0A2082F
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Mar 2019 20:29:41 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726824AbfCSU3k (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Mar 2019 16:29:40 -0400
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:36468 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1726627AbfCSU3k (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Mar 2019 16:29:40 -0400
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2JKTM6L075403
        for <linux-nfs@vger.kernel.org>; Tue, 19 Mar 2019 16:29:39 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2rb7f704cm-1
        (version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
        for <linux-nfs@vger.kernel.org>; Tue, 19 Mar 2019 16:29:38 -0400
Received: from localhost
        by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <linux-nfs@vger.kernel.org> from <zohar@linux.ibm.com>;
        Tue, 19 Mar 2019 20:29:33 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
        by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
        (version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
        Tue, 19 Mar 2019 20:29:30 -0000
Received: from d06av24.portsmouth.uk.ibm.com (mk.ibm.com [9.149.105.60])
        by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x2JKTWx461800526
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Tue, 19 Mar 2019 20:29:32 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
        by IMSVA (Postfix) with ESMTP id BD2C342042;
        Tue, 19 Mar 2019 20:29:32 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
        by IMSVA (Postfix) with ESMTP id 0ED024203F;
        Tue, 19 Mar 2019 20:29:32 +0000 (GMT)
Received: from dhcp-9-31-103-153.watson.ibm.com (unknown [9.31.103.153])
        by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTP;
        Tue, 19 Mar 2019 20:29:31 +0000 (GMT)
Subject: Re: [PATCH v2 3/5] NFSD: Remove ima_file_check call
From:   Mimi Zohar <zohar@linux.ibm.com>
To:     Chuck Lever <chuck.lever@oracle.com>,
        Bruce Fields <bfields@fieldses.org>
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-integrity@vger.kernel.org,
        "Serge E. Hallyn" <serge@hallyn.com>
Date:   Tue, 19 Mar 2019 16:29:31 -0400
In-Reply-To: <872F3DFD-E1A7-443E-B666-25C5931F0748@oracle.com>
References: <20190307151838.11306.94183.stgit@manet.1015granger.net>
         <20190307152854.11306.84006.stgit@manet.1015granger.net>
         <20190308211016.GB27011@fieldses.org>
         <ECE4FD20-840C-4047-9454-27BDF0A905EA@oracle.com>
         <20190308212310.GB28002@fieldses.org>
         <872F3DFD-E1A7-443E-B666-25C5931F0748@oracle.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.20.5 (3.20.5-1.fc24) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19031920-0008-0000-0000-000002CF4635
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19031920-0009-0000-0000-0000223B5AD6
Message-Id: <1553027371.4899.116.camel@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-19_10:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=3 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903190143
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, 2019-03-08 at 16:29 -0500, Chuck Lever wrote:

Thanks Serge for bringing this thread to my attention.  Sorry for the
delay in responding ...

> > On Mar 8, 2019, at 4:23 PM, Bruce Fields <bfields@fieldses.org> wrote:
> > 
> > On Fri, Mar 08, 2019 at 04:11:06PM -0500, Chuck Lever wrote:
> >> 
> >> 
> >>> On Mar 8, 2019, at 4:10 PM, bfields@fieldses.org wrote:
> >>> 
> >>> On Thu, Mar 07, 2019 at 10:28:54AM -0500, Chuck Lever wrote:
> >>>> The NFS server needs to allow NFS clients to perform their own
> >>>> attestation and measurement.

Measurement and attestation is only one aspect.  The other aspect is
verifying the integrity of files.  Shouldn't the NFS server verify the
integrity of a file before allowing it to be served (eg. malware)?

> >>> 
> >>> Can we really remove this call?
> >> 
> >> Why wouldn't we be able to?
> > 
> > I don't know the first thing about IMA, but surely it's there for some
> > reason--
> 
> It was originally added because the number of opens and closes of @file
> were counted, and not having that call was triggering a warning. Since
> commit 8eb988c70e770 ("fix ima breakage") the counters are maintained
> separately.

If that was the only reason, then the call itself would have been
removed with the counter code.

Mimi

> 
> 
> > is it really OK just to skip this on opens by nfsd?
> 
> That's why I split this out into a separate patch. I'm hoping to get
> some commentary from the linux-integrity community.
> 
> 
> > --b.
> > 
> >>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> >>>> ---
> >>>> fs/nfsd/vfs.c |    6 ------
> >>>> 1 file changed, 6 deletions(-)
> >>>> 
> >>>> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> >>>> index 3c00072..524c6e5 100644
> >>>> --- a/fs/nfsd/vfs.c
> >>>> +++ b/fs/nfsd/vfs.c
> >>>> @@ -802,12 +802,6 @@ static int nfsd_open_break_lease(struct inode *inode, int access)
> >>>> 		goto out_nfserr;
> >>>> 	}
> >>>> 
> >>>> -	host_err = ima_file_check(file, may_flags);
> >>>> -	if (host_err) {
> >>>> -		fput(file);
> >>>> -		goto out_nfserr;
> >>>> -	}
> >>>> -
> >>>> 	if (may_flags & NFSD_MAY_64BIT_COOKIE)
> >>>> 		file->f_mode |= FMODE_64BITHASH;
> >>>> 	else
> >> 
> >> --
> >> Chuck Lever
> >> 
> >> 
> 
> --
> Chuck Lever
> 
> 
> 

