Return-Path: <SRS0=ZVvz=NR=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4CD82C32789
	for <linux-nfs@archiver.kernel.org>; Tue,  6 Nov 2018 19:25:41 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 061692085B
	for <linux-nfs@archiver.kernel.org>; Tue,  6 Nov 2018 19:25:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="ksmHRL7N"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 061692085B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=Oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388227AbeKGEwY (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 6 Nov 2018 23:52:24 -0500
Received: from userp2120.oracle.com ([156.151.31.85]:43492 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2387804AbeKGEwY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Nov 2018 23:52:24 -0500
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
        by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wA6JNuT7160652;
        Tue, 6 Nov 2018 19:25:26 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=3JOI3gz1jLm3KHkS6PTfvx5uSsWvLuz08d+s4/KZhp4=;
 b=ksmHRL7NsKpfyMJY2Cs4/h2S/vUEzG6zdSIYSq4MOe3Z1k8wInkh4z8/2xXO+XjnuFya
 AArBqQPPI8N2sfwELhrCesX/sE1IwaYRgsPgbC86R17cAh5e0RVNrdyQin0Rmc5nlEBN
 3B+Jjrw49COdxF35lS7dHOQC9hrfjQ/UrDkPZCygAFjI8U/ww9WZ+KdutjmGKjSS0qC0
 pYgXq/BE3X7ODTxh6sPNmtHlECeoK4AzO+iGMR+pUKiK9JMBgkpzyoZr4Ymbgq6BnLFa
 RhrQ6XF9gLrp+XwsmnPQSd7HAtvLqc9/2O+GriRBenQPZTuMyhy8rMD5wXywfTyke4G1 sA== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
        by userp2120.oracle.com with ESMTP id 2nh4aqq95g-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Tue, 06 Nov 2018 19:25:26 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
        by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id wA6JPJoE008571
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Tue, 6 Nov 2018 19:25:20 GMT
Received: from abhmp0015.oracle.com (abhmp0015.oracle.com [141.146.116.21])
        by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id wA6JPGQ0022134;
        Tue, 6 Nov 2018 19:25:18 GMT
Received: from bills-mac-pro.lan (/24.28.72.193)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Tue, 06 Nov 2018 11:25:15 -0800
Subject: Re: "(deleted)" directories
To:     "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>,
        Malahal Naineni <malahal@gmail.com>
Cc:     NeilBrown <neilb@suse.com>, Marc Eshel <eshel@us.ibm.com>,
        Benjamin Coddington <bcodding@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        linux-nfs-owner@vger.kernel.org,
        Matt Benjamin <mbenjami@redhat.com>,
        trondmy <trondmy@hammerspace.com>
References: <CAGD+tkyTyOb-iiykQLYMoa1h5cmizbe_0M0_HS=9cQC1NDznSw@mail.gmail.com>
 <OF63D29519.B9156C69-ON8825833A.000DEE9B-8825833A.000E8123@notes.na.collabserv.com>
 <87a7mp1k9a.fsf@notabene.neil.brown.name>
 <OFEF532072.6C501ABB-ON8825833B.006B930A-8825833B.006CB5D7@notes.na.collabserv.com>
 <87sh0gz7mt.fsf@notabene.neil.brown.name>
 <CAGD+tkwz_HvBmjwQgLbftf6qU-pL75SJ6a1zq_P239eXMOUDgg@mail.gmail.com>
 <87muqoyutl.fsf@notabene.neil.brown.name>
 <CAGD+tkw5QqZet6n82NavneWK8-_uHo24muxYPj+gqrY=tbk2yA@mail.gmail.com>
 <2003075164.16045771.1541493796820.JavaMail.zimbra@desy.de>
From:   Bill Baker <Bill.Baker@Oracle.com>
Message-ID: <d4c78362-a80c-cff6-8da9-b8872fb750d5@Oracle.com>
Date:   Tue, 6 Nov 2018 13:25:14 -0600
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <2003075164.16045771.1541493796820.JavaMail.zimbra@desy.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9069 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1807170000 definitions=main-1811060167
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 11/6/18 2:43 AM, Mkrtchyan, Tigran wrote:
> 
> 
> ----- Original Message -----
>> From: "Malahal Naineni" <malahal@gmail.com>
>> To: "NeilBrown" <neilb@suse.com>
>> Cc: "Marc Eshel" <eshel@us.ibm.com>, "Benjamin Coddington" <bcodding@redhat.com>, "linux-nfs"
>> <linux-nfs@vger.kernel.org>, linux-nfs-owner@vger.kernel.org, "Matt Benjamin" <mbenjami@redhat.com>, "trondmy"
>> <trondmy@hammerspace.com>
>> Sent: Monday, November 5, 2018 8:40:16 AM
>> Subject: Re: "(deleted)" directories
> 
>>>> My reading of section 10.3.4 of RFC7530 suggests that the client should
>> generally compare fsid and fileid to see if two different filehandles refer to
>> the same object or not.
>>
>> Section 10.3.4 is for files only correct? The issue here is for
>> directories. Also, Trond clearly pointed that Linux breaks section
>> 10.3.4 from his email stating "We treat always different filehandles
>> as if they refer to different
>> files. It has long been the case that snapshots from several vendors
>> are encoded to look like the same file (same fileid + same  fsid) and
>> differing only by filehandle. If we were to try to consolidate those
>> inodes we would end up corrupting application data."
>>
>> We don't respect either NFSv3 or NFSv4 RFCs in this regard!
> 
> 
> In general, you are right. The spec is our source of truth. However,
> I wouldn't rely on any word in the rfc if it wasn't implemented and
> tested by various client and server implementations (this is IETF requirement!).
> That's why we run multiple bake-a-thons and connectathons. Moreover,
> from my experience of having outsider server implementation I can say,
> that even if desired change end-up in upstream kernel, there are clients
> around that don't support that functionality and will force you to solve
> have a solutionin the server side.
> 
> BTW, at the one of the connectathons, Bill Baker from Oracle was telling
> about migration implementation on Solaris server. And one of the issues
> that thy suffer from was that file handles was in host native format and
> they had a problems in migration from SPARC to x64. I am supersized, that
> you run into the same issue.
> 


Yeah, though that is just an error in implementation.  ZFS stores
it's persistent data in network byte order so that the a filesystem
can be imported on machines with different byte orders.  +1 for the
ZFS guys, but sadly the NFS server failed to xdr encode the file
handle need to enable FH portability between architectures.  -1 for
the (Solaris) NFS guys.  Fixed for 4.1 file handles, though.

<snip>



-- 
Bill Baker, Oracle Linux NFS development
