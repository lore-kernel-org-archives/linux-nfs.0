Return-Path: <SRS0=leyo=NN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	T_DKIMWL_WL_HIGH,UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6309C65C22
	for <linux-nfs@archiver.kernel.org>; Fri,  2 Nov 2018 17:42:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6FF822082E
	for <linux-nfs@archiver.kernel.org>; Fri,  2 Nov 2018 17:42:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="vnGS0hx5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6FF822082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726707AbeKCCuk (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 2 Nov 2018 22:50:40 -0400
Received: from aserp2120.oracle.com ([141.146.126.78]:42644 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726700AbeKCCuj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Nov 2018 22:50:39 -0400
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
        by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wA2Hddkn190831;
        Fri, 2 Nov 2018 17:42:37 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 content-transfer-encoding : in-reply-to; s=corp-2018-07-02;
 bh=dx/++gzJdspSUvNHaN5Vmj/odzlQqUqOQMuM8bcPyyE=;
 b=vnGS0hx5nG6MCMM/2w1QA7u+WHsRpux3ad7HGHsgCMf7wO4DuIq7lLbYq7dXHOq0zcFy
 qzn6LNY5BjfsX3KhgNzXOKs0LCLWcmXHvEV3HbAIfZhLygEJRQ04kd/kN4i70cOEYCLI
 /qRpBZgWghFE5yeGTBM21mmQUUhfzgGV+WsKUkYKSGgtfDi9M+h4t8q0tQNQTsBMzJSL
 9bGIH4naY/r/Op9G61XZvgsfgc5DA/ah27w6T8pfTFb/ylyEzElh8XA7lnOXmc9pbeWZ
 AXcFCJNiv3W+BKR1lm8m/CiHgR+ZIDxyuNO6LtYxLTQrlANX1dBfbwAI1FcjWeT8Oon1 9Q== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
        by aserp2120.oracle.com with ESMTP id 2ncfyqfw2f-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Fri, 02 Nov 2018 17:42:37 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
        by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id wA2HgV1U021236
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Fri, 2 Nov 2018 17:42:31 GMT
Received: from abhmp0018.oracle.com (abhmp0018.oracle.com [141.146.116.24])
        by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id wA2HgVdb003626;
        Fri, 2 Nov 2018 17:42:31 GMT
Received: from localhost (/67.169.218.210)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Fri, 02 Nov 2018 10:42:31 -0700
Date:   Fri, 2 Nov 2018 10:42:29 -0700
From:   "Darrick J. Wong" <darrick.wong@oracle.com>
To:     Filipe Manana <fdmanana@gmail.com>
Cc:     Dave Chinner <david@fromorbit.com>,
        Eric Sandeen <sandeen@redhat.com>, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-xfs@vger.kernel.org, linux-mm@kvack.org,
        linux-btrfs <linux-btrfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        ocfs2-devel@oss.oracle.com
Subject: Re: [PATCH 05/25] vfs: avoid problematic remapping requests into
 partial EOF block
Message-ID: <20181102174229.GA4127@magnolia>
References: <153923113649.5546.9840926895953408273.stgit@magnolia>
 <153923117420.5546.13317703807467393934.stgit@magnolia>
 <CAL3q7H7mLvCGpyitJhQ=To-aDvG9k9rxSVi2jSpcALQVj3myzg@mail.gmail.com>
 <20181015003139.GZ6311@dastard>
 <CAL3q7H5ofBmjh0DmbPH6Rmm523JV9byuBiYj=Jxpc44Kbh+Haw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAL3q7H5ofBmjh0DmbPH6Rmm523JV9byuBiYj=Jxpc44Kbh+Haw@mail.gmail.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9065 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1807170000 definitions=main-1811020156
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Nov 02, 2018 at 12:04:39PM +0000, Filipe Manana wrote:
> On Mon, Oct 15, 2018 at 1:31 AM Dave Chinner <david@fromorbit.com> wrote:
> >
> > On Fri, Oct 12, 2018 at 09:22:18PM +0100, Filipe Manana wrote:
> > > On Thu, Oct 11, 2018 at 5:13 AM Darrick J. Wong <darrick.wong@oracle.com> wrote:
> > > >
> > > > From: Darrick J. Wong <darrick.wong@oracle.com>
> > > >
> > > > A deduplication data corruption is exposed by fstests generic/505 on
> > > > XFS.
> > >
> > > (and btrfs)
> > >
> > > Btw, the generic test I wrote was indeed numbered 505, however it was
> > > never committed and there's now a generic/505 which has nothing to do
> > > with deduplication.
> > > So you should update the changelog to avoid confusion.
> >
> > What test is it now? And if it hasn't been committed, are you going
> > to update it and repost as it clearly had value....
> 
> Sorry, I lost track of this.
> 
> So what was the conclusion of the thread where discussion about this
> problem started?
> It wasn't clear to me if a consensus was reached and got lost on that
> long user space dedupe tools discussion between you and Zygo.
> 
> The test assumed a fix of rounding down the range and deduping less
> bytes then requested (which ended up included in 4.19 for btrfs).
> 
> From this vfs patch it seems it was decided to return errno -EDADE instead.
> Is this the final decision?

No, I reworked the whole mess to match btrfs-4.19 behavior of deduping
fewer bytes than requested.

--D

> >
> > Cheers,
> >
> > Dave.
> > --
> > Dave Chinner
> > david@fromorbit.com
> 
> 
> 
> -- 
> Filipe David Manana,
> 
> “Whether you think you can, or you think you can't — you're right.”
