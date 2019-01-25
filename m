Return-Path: <SRS0=p/Fe=QB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59478C282C0
	for <linux-nfs@archiver.kernel.org>; Fri, 25 Jan 2019 20:57:42 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1D8CB218A6
	for <linux-nfs@archiver.kernel.org>; Fri, 25 Jan 2019 20:57:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="GGGwLaYB"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726218AbfAYU5l (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 25 Jan 2019 15:57:41 -0500
Received: from userp2130.oracle.com ([156.151.31.86]:51692 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726044AbfAYU5l (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Jan 2019 15:57:41 -0500
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
        by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id x0PKmvL8113660;
        Fri, 25 Jan 2019 20:57:32 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=37shyhFlcZYOoIdud8SZfFFTEQLqS8NoGmsde+YcCIo=;
 b=GGGwLaYBGRxPSj/8U64aH7xvEMQp9jEwdPD6JKJR3uGXEjV6q9wzQKwQwFanA8d2Df3P
 l5zF4QaXvoy8qc8ugWOOTqVRhEds/6vWqnucDc817AvTL1cqsUUHtPsrhqOf+aE7t+xZ
 bG3zvsSipc5R6xdLrHbnR64dRUQ+vaBWeg3bqu5YlbI6RPupUOKN7D5xKkYXSrUHIsYg
 RRDKQne8pY7Wn3S4Q/N3vSaq/1sHpzW3ShXC5zqELk0PLDdGM2WSfVlR61soU30ojoby
 1jHbjvaYNglWDSr55IYbV0g5w8pb/RgFZRxS1EmiFNSKv8Krb4H9oT9dEWIBaHC15Qsg Qg== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
        by userp2130.oracle.com with ESMTP id 2q3uav7yxn-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Fri, 25 Jan 2019 20:57:31 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
        by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x0PKvUlU016863
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Fri, 25 Jan 2019 20:57:31 GMT
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
        by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x0PKvUR4030116;
        Fri, 25 Jan 2019 20:57:30 GMT
Received: from localhost (/67.169.218.210)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Fri, 25 Jan 2019 12:57:29 -0800
Date:   Fri, 25 Jan 2019 12:57:26 -0800
From:   "Darrick J. Wong" <darrick.wong@oracle.com>
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     Olga Kornievskaia <aglo@umich.edu>,
        Trond Myklebust <trondmy@gmail.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsd: Fix error return values for
 nfsd4_clone_file_range()
Message-ID: <20190125205726.GA19328@magnolia>
References: <20190121205838.18680-1-trond.myklebust@hammerspace.com>
 <20190125004658.GB3953@fieldses.org>
 <698446e18a6718ee1ced06ecfd06e2de802fa16e.camel@gmail.com>
 <20190125163218.GA2752@fieldses.org>
 <CAN-5tyEZhVEMSjxbWfGoODb6eAmO7VJLjYkMv2HwUyXKHjyyWw@mail.gmail.com>
 <20190125201037.GA5173@fieldses.org>
 <20190125201551.GB5173@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190125201551.GB5173@fieldses.org>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9147 signatures=668682
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1901250160
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Jan 25, 2019 at 03:15:51PM -0500, J. Bruce Fields wrote:
> On Fri, Jan 25, 2019 at 03:10:37PM -0500, J. Bruce Fields wrote:
> > Yeah.  I was assuming it could happen in the case you ask to clone
> > beyond the end of the source file.  But looking at the code, there's a
> > check for that case in generic_remap_checks() before doing the clone,
> > and while holding a write lock on i_rwsem (I assume that's enough to
> > hold the file size constant).  At least that's true in the cases (btrfs
> > & xfs) that I checked.
> > 
> > So, I don't know, maybe that check is just dead code.
> 
> In the xfs case it looks like the main work of the clone is done in
> xfs_reflink_remap_blocks(), where there's a loop like:
> 
> 	while (len) {
> 		... mysterious code that clones range_len worth of
> 		    extents?
> 		if (fatal_signal_pending(current)) {
> 			error =-EINTR;
> 			break;
> 		}
> 		...
> 		len -= range_len;
> 		remapped_len += range_len;
> 	}
> 
> And then it ends up returning remapped_len if it's positive.

Hmm?  In xfs_reflink_remap_blocks, *remapped (an out parameter) is set
to remapped_len just prior to returning whatever error is.  The caller
(xfs_file_remap_range) can see how many bytes were remapped, as well as
any error that might have cut short the remapping process...

> So it looks to me like if you do a big clone on xfs and kill the
> process, it can clone part of the range, return the amount cloned, and
> then the ioctl code will throw away that amount and just return EINVAL,

...and so xfs_file_remap_range will return the number of bytes remapped
before it returns any error codes.  This was done so that
copy_file_range can call remap_file_range and report a short but
otherwise successful copy.

Yes, it's sort of dumb that we pass the "bytes remapped" information all
the way up the call stack only to have the clonerange ioctl spit back
EINVAL on a short remap, but we're stuck with that (poorly thought out)
artifact of btrfs.

Note that XFS can return cloned < count if (for example) it runs out of
space trying to expand the extent map btree to add more extents.

> with the result that the application thinks the operation failed
> completely actually it cloned a bunch of data.

(Yes, the ioctl is dumb; I would say that programs should use
copy_file_range instead as a less bad interface, but the splice copy
fallback is ...  yuck.)

--D

> --b.
