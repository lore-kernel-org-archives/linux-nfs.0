Return-Path: <SRS0=PHUf=OT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6CC5C04EB8
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 17:49:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6FFF320851
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 17:49:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="N40JQK2W"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6FFF320851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728288AbeLJRtJ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 10 Dec 2018 12:49:09 -0500
Received: from userp2130.oracle.com ([156.151.31.86]:37818 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728202AbeLJRtJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2018 12:49:09 -0500
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
        by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wBAHiA7v087657;
        Mon, 10 Dec 2018 17:49:05 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=q1u/8WJ8+GEdPeucOQdnXMHbVquXKssSepZHA5oG8X4=;
 b=N40JQK2WykQo7zZjpDFcLMj9xRjd0mqiCpALndVGSUNwc5u8R9h9K5045L7tKWE3cyQP
 nebfsKCJE08yFWr0+wDFqThQ6Lda9P+Qn129u1rtxWalnXxBtv0MVTsAdxmT101VUT9x
 A8YjW3l1Sgd9+AdF1NyykdzyJFf/LpniMk9lIe3BbCp6uqjLvLdhK0gLzrjnPJzyXOoD
 ZV57LNcTejW/yuPKBze1WmS7DfP/bv3pIrQaiQgRnrTzBARSUHILr5I0cwUK5EU1fjSp
 9TdZ8zRFUuFzQNX69Ot42rjQDlkw1FKwgmZqGd3ctmlDrOBp/mbHOmCuIdPF1Ud6jPLx kA== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
        by userp2130.oracle.com with ESMTP id 2p85ctyfxv-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 10 Dec 2018 17:49:05 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
        by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id wBAHn4UI012920
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 10 Dec 2018 17:49:04 GMT
Received: from abhmp0008.oracle.com (abhmp0008.oracle.com [141.146.116.14])
        by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id wBAHn4eH006199;
        Mon, 10 Dec 2018 17:49:04 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Mon, 10 Dec 2018 09:49:04 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: listing knfsd-held locks and opens
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20181210174720.GA2925@fieldses.org>
Date:   Mon, 10 Dec 2018 12:49:02 -0500
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org, Jeff Layton <jlayton@redhat.com>
Content-Transfer-Encoding: 7bit
Message-Id: <08F6A3D9-6FF3-452A-BCD6-390ECA142136@oracle.com>
References: <20181210174720.GA2925@fieldses.org>
To:     Bruce Fields <bfields@fieldses.org>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9103 signatures=668679
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1812100159
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Dec 10, 2018, at 12:47 PM, bfields@fieldses.org wrote:
> 
> We've got a long-standing complaint that tools like lsof, when run on an
> NFS server, overlook opens and locks held by NFS clients.
> 
> The information's all there, it's just a question of how to expose it.
> 
> Easiest might be a single flat file like /proc/locks, but I've always
> hoped we could do something slightly more structured, using a
> subdirectory per NFS client.
> 
> Jeff Layton looked into this several years ago.  I don't remember if
> there was some particular issue or if he just got bogged down in VFS
> details.
> 
> My concerns are that:
> 
> 	- I'd like the format to be easily expandable.  The option to
> 	  create new files seems like it would help.
> 	- some of the data we'd like to expose may be kind of cumbersome
> 	  include as a column in a text file.  (I'm thinking of the
> 	  NFSv4 client identifier, which the protocol allows to be up to
> 	  1K of binary data, even if most (all?) clients use shorter
> 	  ascii identifiers.)
> 
> I'm not sure I'd want to go as far as a sysfs-like one-value-per-file
> rule, which seems like overkill?
> 
> In a little more detail, as starting point, I was considering naming
> each client directory with a small integer, and including files like:
> 
> 	info: a text file with
> 		NFS protocol version
> 		ascii representation of client address
> 		krb5 principal if available
> 
> 	clientid: NFSv4 client ID; file absent for NFSv2/3 clients.
> 
> 	locks: list of locks, following something like the /proc/locks
> 		format.
> 
> 	opens: list of file opens, with access bits, inode numbers,
> 		device number.
> 
> Does that sound reasonable?  Any other ideas?

How do you plan to make this kernel API namespace-aware?

--
Chuck Lever



