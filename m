Return-Path: <SRS0=fB6X=RY=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC615C10F00
	for <linux-nfs@archiver.kernel.org>; Thu, 21 Mar 2019 14:06:16 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9D154218E2
	for <linux-nfs@archiver.kernel.org>; Thu, 21 Mar 2019 14:06:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="PiC4xFsv"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728195AbfCUOGP (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 21 Mar 2019 10:06:15 -0400
Received: from userp2130.oracle.com ([156.151.31.86]:43086 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727829AbfCUOGP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Mar 2019 10:06:15 -0400
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
        by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x2LE44f3159216;
        Thu, 21 Mar 2019 14:04:41 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=S+fJLyVs9wwdhWJ0hfw/N7t0OcrrDwTuJKscNHz+YHk=;
 b=PiC4xFsvmZv9FNE7uwEtEDBijTays2Kkew7+QCgDZDdhBG0xkRkYIucTUtRMJ/f5Fo9C
 W8nCvYOCzcsL57zsRajs7O3yKjNmfsyX+sUJt3FZAKd+sAE+pVfG1POTKuXZ+SE+xtbI
 u1SmL7qrKZS2geBbmm1JD80WizaOyOyIdBBC2p0iuDAyC8oHq007ZHnWTu5XMNXrkA1s
 Fq0WAfrK3cyz28wwszWdQz87uU/3X8hPdhOUQgUwTu192uGWYrfFA2scf+69+qhzaHYz
 9RuruPvxn9K5XC8c2hIS6e51x1Kk+LkmRmoKCAAhVY4NrPLJdYSFVveB1Sz0HgAVL9/p tQ== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
        by userp2130.oracle.com with ESMTP id 2r8rjv0muq-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Thu, 21 Mar 2019 14:04:40 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
        by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x2LE4YAc023662
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Thu, 21 Mar 2019 14:04:34 GMT
Received: from abhmp0011.oracle.com (abhmp0011.oracle.com [141.146.116.17])
        by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x2LE4YCH030283;
        Thu, 21 Mar 2019 14:04:34 GMT
Received: from [100.66.188.10] (/198.214.85.110)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Thu, 21 Mar 2019 07:04:34 -0700
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH v2 3/5] NFSD: Remove ima_file_check call
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1553168687.4899.396.camel@linux.ibm.com>
Date:   Thu, 21 Mar 2019 09:04:34 -0500
Cc:     Bruce Fields <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-integrity@vger.kernel.org,
        "Serge E. Hallyn" <serge@hallyn.com>
Content-Transfer-Encoding: 7bit
Message-Id: <D2C155AD-7888-43CB-A25A-461FF474BDB7@oracle.com>
References: <20190307151838.11306.94183.stgit@manet.1015granger.net>
 <20190307152854.11306.84006.stgit@manet.1015granger.net>
 <20190308211016.GB27011@fieldses.org>
 <ECE4FD20-840C-4047-9454-27BDF0A905EA@oracle.com>
 <20190308212310.GB28002@fieldses.org>
 <872F3DFD-E1A7-443E-B666-25C5931F0748@oracle.com>
 <1553027371.4899.116.camel@linux.ibm.com>
 <0E02D70A-A5E9-4B27-9922-521D5A0755A3@oracle.com>
 <1553168687.4899.396.camel@linux.ibm.com>
To:     Mimi Zohar <zohar@linux.ibm.com>
X-Mailer: Apple Mail (2.3445.102.3)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9201 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1903210100
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Mar 21, 2019, at 6:44 AM, Mimi Zohar <zohar@linux.ibm.com> wrote:
> 
> On Wed, 2019-03-20 at 08:40 -0500, Chuck Lever wrote:
>> 
>>> On Mar 19, 2019, at 3:29 PM, Mimi Zohar <zohar@linux.ibm.com> wrote:
>>> 
>>> On Fri, 2019-03-08 at 16:29 -0500, Chuck Lever wrote:
>>> 
>>> Thanks Serge for bringing this thread to my attention.  Sorry for the
>>> delay in responding ...
>>> 
>>>>> On Mar 8, 2019, at 4:23 PM, Bruce Fields <bfields@fieldses.org> wrote:
>>>>> 
>>>>> On Fri, Mar 08, 2019 at 04:11:06PM -0500, Chuck Lever wrote:
>>>>>> 
>>>>>> 
>>>>>>> On Mar 8, 2019, at 4:10 PM, bfields@fieldses.org wrote:
>>>>>>> 
>>>>>>> On Thu, Mar 07, 2019 at 10:28:54AM -0500, Chuck Lever wrote:
>>>>>>>> The NFS server needs to allow NFS clients to perform their own
>>>>>>>> attestation and measurement.
>>> 
>>> Measurement and attestation is only one aspect.  The other aspect is
>>> verifying the integrity of files.  Shouldn't the NFS server verify the
>>> integrity of a file before allowing it to be served (eg. malware)?
>> 
>> Hi Mimi, thanks for the review.
>> 
>> Architecturally, the server is not using the file's data, it is
>> merely part of the filesystem that stores it. But that said, there
>> are several concrete reasons why I feel an NFS server should not be
>> involved in measurement/attestation, but only with storing file
>> content and IMA metadata.
> 
> "Remote attestation" is the process of verifying the measurement list
> against the TPM PCRs, based on a TPM quote.  I think you meant
> "measurement/appraisal".
> 
>> 
>> 1. The broadest attack surface for a remote filesystem is modification
>> of data in flight. Attestation of the file on the server is not going
>> to defend against that attack, only attestation on the client will do
>> that. Is there a good reason to pay the cost of double attestation?
> 
> Doesn't the server have a responsibility to provide files that have
> not been unintentionally or maliciously altered?

It's a design goal of any filesystem to present unaltered file data
to applications. But the responsibility is end-to-end. Adding extra
checks in the middle introduce a cost. Measuring on the client is
sufficient, and it is equivalent to what local filesystems do (and,
it allows each client to apply its own security policy).

I'm going to claim here without proof that there is little value in
using IMA on an NFS server that serves NFS clients that are not
IMA-aware. :-)


>> 2. It is possible (perhaps even likely) that the NFS server and a
>> client of that server will have different IMA policies and even
>> different file signing authorities.
> 
> That doesn't negate the due diligence on the server's part of
> preventing the spread of malware.

Commercial NFS servers (like NetApp filers) perform malware and
integrity checking via a scrubbing agent rather than checking in a
hot path. Filesystems are not only responsible for leaving data
unchanged, they also have performance requirements.


>> A third, perhaps related, reason is that NFS can run on non-Linux NFS
>> servers which would not have any attestation at all. An NFS client
>> should not have to rely on the server for attestation, but should
>> trust only its own measurement of each file, which would be done as
>> late as possible before use.
> 
> The ima_file_check() hook can also audit the file, providing
> additional forensic information (eg. the file hash).

IIUC, you are talking about troubleshooting, which should be
rare. That can be done with tools on the server if needed, but
IMO can be avoided in performance-sensitive paths.


> Mimi
> 
>> 
>> Lastly, the NFS protocol does not enable an NFS client to tell a
>> server how the file is to be used. For example, the server's policy
>> might block execution of an unverifiable file, but the server won't
>> have any way of knowing how the client is going to use that file.
>> The client might be opening the file to copy it or update its IMA
>> metadata.
>> 
>> Speaking of protocol, there's no special error code that reports an
>> integrity verification failure. The client just sees that the UID
>> does not have access to the file. There's no way the user or client
>> can do anything to clear this condition via NFS without IMA support.
>> 
>> If these reasons make sense, should I add them to the patch description?

--
Chuck Lever



