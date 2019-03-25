Return-Path: <SRS0=29O7=R4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	UNPARSEABLE_RELAY autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8941BC10F03
	for <linux-nfs@archiver.kernel.org>; Mon, 25 Mar 2019 14:24:36 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 59B1E2084D
	for <linux-nfs@archiver.kernel.org>; Mon, 25 Mar 2019 14:24:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="gz+iOEkB"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725795AbfCYOYf (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 25 Mar 2019 10:24:35 -0400
Received: from userp2120.oracle.com ([156.151.31.85]:44564 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725788AbfCYOYf (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Mar 2019 10:24:35 -0400
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
        by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x2PEIc2x058231;
        Mon, 25 Mar 2019 14:24:20 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=l3385Of8Brw7RcOodlBzpYT1ijP8OHlpayF360Vgojc=;
 b=gz+iOEkBCRegFSlzxL1pFe57aLghbMZQ8IO9kbKvh58SqqcqrWV7ixhQTg5reWGhc7Xw
 L2LAa/brbosCn9S4nZ25v6GPvarvtRHEHZqEoZqxJr2w/TakXwNIWPi+jgVlfsYcsXjm
 zFiQ9bF94c1Jse6HCHIq+/I1TEvZyBWx/TUckdSk9wq3NutsPQnvko0lE5ma3UWEMQLX
 uPJVW6eqN50p3V6EozRXTYdjyegjGK/ZEWCCGoFFOKyjprdVU4iiTkM+LMJp5LGbmSno
 0HFNh/EbjOslzE7QvHPqT/hxanNV2A5jBFBaPjkrDruwh+pVwzMQUjVNVvNH2jx1rAWG Ow== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
        by userp2120.oracle.com with ESMTP id 2re6dj4cc8-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 25 Mar 2019 14:24:20 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
        by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x2PEOJ3G000385
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 25 Mar 2019 14:24:19 GMT
Received: from abhmp0004.oracle.com (abhmp0004.oracle.com [141.146.116.10])
        by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x2PEOGov000661;
        Mon, 25 Mar 2019 14:24:19 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Mon, 25 Mar 2019 07:24:16 -0700
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH v2 3/5] NFSD: Remove ima_file_check call
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1553295305.5291.40.camel@linux.ibm.com>
Date:   Mon, 25 Mar 2019 10:24:14 -0400
Cc:     Bruce Fields <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-integrity@vger.kernel.org,
        "Serge E. Hallyn" <serge@hallyn.com>
Content-Transfer-Encoding: quoted-printable
Message-Id: <E51D17F4-5641-48D9-A2A2-56D13F44DF75@oracle.com>
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
To:     Mimi Zohar <zohar@linux.ibm.com>
X-Mailer: Apple Mail (2.3445.102.3)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9205 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1903250107
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Mar 22, 2019, at 6:55 PM, Mimi Zohar <zohar@linux.ibm.com> wrote:
>=20
> On Thu, 2019-03-21 at 09:04 -0500, Chuck Lever wrote:
>>=20
>>> On Mar 21, 2019, at 6:44 AM, Mimi Zohar <zohar@linux.ibm.com> wrote:
>>> On Wed, 2019-03-20 at 08:40 -0500, Chuck Lever wrote:
>>>>> On Mar 19, 2019, at 3:29 PM, Mimi Zohar <zohar@linux.ibm.com> =
wrote:
>>>>> On Fri, 2019-03-08 at 16:29 -0500, Chuck Lever wrote:
>>>>> Thanks Serge for bringing this thread to my attention.  Sorry for =
the
>>>>>>> On Mar 8, 2019, at 4:23 PM, Bruce Fields <bfields@fieldses.org> =
wrote:
>>>>>>> On Fri, Mar 08, 2019 at 04:11:06PM -0500, Chuck Lever wrote:
>>>>>>>>> On Mar 8, 2019, at 4:10 PM, bfields@fieldses.org wrote:
>>>>>>>>> On Thu, Mar 07, 2019 at 10:28:54AM -0500, Chuck Lever wrote:
>>>>>>>>>> The NFS server needs to allow NFS clients to perform their =
own
>>>>>>>>>> attestation and measurement.
>>>>>=20
>>>>> Measurement and attestation is only one aspect.  The other aspect =
is
>>>>> verifying the integrity of files.  Shouldn't the NFS server verify =
the
>>>>> integrity of a file before allowing it to be served (eg. malware)?
>>>>=20
>>>> Hi Mimi, thanks for the review.
>>>>=20
>>>> Architecturally, the server is not using the file's data, it is
>>>> merely part of the filesystem that stores it. But that said, there
>>>> are several concrete reasons why I feel an NFS server should not be
>>>> involved in measurement/attestation, but only with storing file
>>>> content and IMA metadata.
>>>=20
>>> "Remote attestation" is the process of verifying the measurement =
list
>>> against the TPM PCRs, based on a TPM quote.  I think you meant
>>> "measurement/appraisal".
>>>=20
>>>>=20
>>>> 1. The broadest attack surface for a remote filesystem is =
modification
>>>> of data in flight. Attestation of the file on the server is not =
going
>>>> to defend against that attack, only attestation on the client will =
do
>>>> that. Is there a good reason to pay the cost of double attestation?
>>>=20
>>> Doesn't the server have a responsibility to provide files that have
>>> not been unintentionally or maliciously altered?
>>=20
>> It's a design goal of any filesystem to present unaltered file data
>> to applications. But the responsibility is end-to-end. Adding extra
>> checks in the middle introduce a cost.=20
>=20
> Files are measured/appraised/audited based on the IMA policy.  Have
> you measured the performance cost of measuring and appraising the
> files being served?  Unless a policy has been supplied, the
> performance impact, if any, would be limited to walking the IMA policy
> rules.

I have not measured the performance cost, but I'm simply observing
that it could be substantial in some cases.

nfsd_open is called in the NFSv3 READ and WRITE paths, in addition to
whenever a file is locked (NFSv3) or opened (NFSv4). The impact is
small when there is no IMA policy, but could be substantial when there
is an IMA policy in effect.

Note that NFSv3 does not have an OPEN operation. I'm not sure what
would be an adequate substitute location for an IMA hash audit for
NFSv3 file accesses.

Measuring on the client gives us the most effective integrity coverage
and an implementation that is closest in behavior to local filesystem
semantics. I'm just saying I'd rather not measure twice, because it
doesn't provide a great benefit (more below) and can be costly. I agree
that we should figure out a way to assess its performance impact.


>> Measuring on the client is
>> sufficient, and it is equivalent to what local filesystems do (and,
>> it allows each client to apply its own security policy).
>=20
> I'm not arguing with you about an end-to-end file integrity solution.
>  That is the goal, but one that assumes this proposed work, based on
> fs-verity signatures.
>=20
>> I'm going to claim here without proof that there is little value in
>> using IMA on an NFS server that serves NFS clients that are not
>> IMA-aware. :-)
>=20
> For systems that don't or haven't implemented the proposed end-to-end
> file integrity solution, verifying the file integrity on the server is
> all the more important.

As I said before, the largest integrity exposure is modification of
file data as it is transported between server and client -- _after_ the
server has measured it. IMHO that makes measuring on the server a bit
of security theatre.

In addition to that, ima_file_check returns -EACCES if it fails (and
the IMA policy is in enforcing mode). That is a confusing situation
for NFS, since that looks like the user does not have permission to
access the file (ie, that it can be corrected by the user by changing
an ACL or mode bits).

Maybe NFS should have new error codes that can convey "blocked by
administrative policy" or "failed integrity check". In the meantime,
though, existing NFS systems without any IMA support do not have these
codes.


>>>> 2. It is possible (perhaps even likely) that the NFS server and a
>>>> client of that server will have different IMA policies and even
>>>> different file signing authorities.
>>>=20
>>> That doesn't negate the due diligence on the server's part of
>>> preventing the spread of malware.
>>=20
>> Commercial NFS servers (like NetApp filers) perform malware and
>> integrity checking via a scrubbing agent rather than checking in a
>> hot path. Filesystems are not only responsible for leaving data
>> unchanged, they also have performance requirements.
>=20
> Any userspace application leaves a window of opportunity between the
> time the file has been created/modified and the time that the
> application verifies it.  This is one of the main reason for IMA being
> in the kernel.
>=20
>>=20
>>>> A third, perhaps related, reason is that NFS can run on non-Linux =
NFS
>>>> servers which would not have any attestation at all. An NFS client
>>>> should not have to rely on the server for attestation, but should
>>>> trust only its own measurement of each file, which would be done as
>>>> late as possible before use.
>>>=20
>>> The ima_file_check() hook can also audit the file, providing
>>> additional forensic information (eg. the file hash).
>>=20
>> IIUC, you are talking about troubleshooting, which should be
>> rare. That can be done with tools on the server if needed, but
>> IMO can be avoided in performance-sensitive paths.
>=20
> No, this isn't about "troubleshooting", but about auditing the files
> served and using the file hashes for forensic investigations.[1][2]
>=20
> Mimi
>=20
> [1] Commit e7c568e0fd0c ("ima: audit log hashes")
> [2] =
https://www.fireeye.com/blog/threat-research/2016/11/extending_linux_exec.=
html

Auditing can be done by keeping the ima_file_check call site but
ignoring its return code, for example.

In any event, removing the ima_file_check call is not required for
the prototype to be functional. I can drop this patch for now, but
I encourage examination of how the NFS server measures and audits
files when an actual IMA policy is in effect.


--
Chuck Lever



