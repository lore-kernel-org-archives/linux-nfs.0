Return-Path: <SRS0=4jnv=OM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F0953C04EB9
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 19:11:38 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B7CB320848
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 19:11:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="oE60gd9y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B7CB320848
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726044AbeLCTLj (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 3 Dec 2018 14:11:39 -0500
Received: from userp2120.oracle.com ([156.151.31.85]:47130 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725987AbeLCTLj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Dec 2018 14:11:39 -0500
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
        by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wB3J3d4g033513;
        Mon, 3 Dec 2018 19:11:33 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=npRy/f8qZDzX/wpE4CbdsG0mnbzF9zNJXzFByhFdrjY=;
 b=oE60gd9ye1X74qDSyxICCrhR24aXYP2E7paxTz3MqOyrHWj8y5AS7mKT+8jqQ31I2yL7
 MuqL+VyTg9E8funBIHGPgXXsIT+svBi8qQBeRrnBx10HJWluMmGLuL6EbtyjQj/Y50ZT
 cGxWHAI2Cq6QJyrQQj3lz7rTmO8Iw9TdThMLiIR24mJHMOeEvpV68Db3ivKrMSuh9Q6G
 RUvSgfgUiFuaKmjb28QqwTz3KqImysakDV2J+ahYXsczT5Vjsub/D3nPqY1+CKeuF8aO
 araWol8MLKqQ7iw28lWngrZtTFeNPntPmJw+A74pjoNXli1sHEBx1WwZ8cVuRTcwOjZq gA== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
        by userp2120.oracle.com with ESMTP id 2p3jxr87dj-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 03 Dec 2018 19:11:33 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
        by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id wB3JBXL2001386
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 3 Dec 2018 19:11:33 GMT
Received: from abhmp0019.oracle.com (abhmp0019.oracle.com [141.146.116.25])
        by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id wB3JBWH3009224;
        Mon, 3 Dec 2018 19:11:32 GMT
Received: from localhost (/67.169.218.210)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Mon, 03 Dec 2018 11:11:32 -0800
Date:   Mon, 3 Dec 2018 11:11:30 -0800
From:   "Darrick J. Wong" <darrick.wong@oracle.com>
To:     Amir Goldstein <amir73il@gmail.com>
Cc:     Dave Chinner <david@fromorbit.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-xfs <linux-xfs@vger.kernel.org>,
        Olga Kornievskaia <olga.kornievskaia@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        overlayfs <linux-unionfs@vger.kernel.org>,
        ceph-devel@vger.kernel.org, linux-cifs@vger.kernel.org
Subject: Re: [PATCH 08/11] vfs: push EXDEV check down into ->remap_file_range
Message-ID: <20181203191130.GD24487@magnolia>
References: <20181203083416.28978-1-david@fromorbit.com>
 <20181203083416.28978-9-david@fromorbit.com>
 <CAOQ4uxgwZLsO1yV37_CHaZ-O+-+-OggSP9g6m9YE57kLPc5yDw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOQ4uxgwZLsO1yV37_CHaZ-O+-+-OggSP9g6m9YE57kLPc5yDw@mail.gmail.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9096 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=815
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1812030176
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Dec 03, 2018 at 01:04:07PM +0200, Amir Goldstein wrote:
> On Mon, Dec 3, 2018 at 10:34 AM Dave Chinner <david@fromorbit.com> wrote:
> >
> > From: Dave Chinner <dchinner@redhat.com>
> >
> > before we can enable cross-device copies into copy_file_range(),
> > we have to ensure that ->remap_file_range() implemenations will
> > correctly reject attempts to do cross filesystem clones. Currently
> 
> But you only fixed remap_file_range() implemenations of xfs and ocfs2...
> 
> > these checks are done above calls to ->remap_file_range(), but
> > we need to drive them inwards so that we get EXDEV protection for all
> > callers of ->remap_file_range().
> >
> > Signed-off-by: Dave Chinner <dchinner@redhat.com>
> > ---
> >  fs/read_write.c | 21 +++++++++++++--------
> >  1 file changed, 13 insertions(+), 8 deletions(-)
> >
> > diff --git a/fs/read_write.c b/fs/read_write.c
> > index 3288db1d5f21..174cf92eea1d 100644
> > --- a/fs/read_write.c
> > +++ b/fs/read_write.c
> > @@ -1909,6 +1909,19 @@ int generic_remap_file_range_prep(struct file *file_in, loff_t pos_in,
> >         bool same_inode = (inode_in == inode_out);
> >         int ret;
> >
> > +       /*
> > +        * FICLONE/FICLONERANGE ioctls enforce that src and dest files are on
> > +        * the same mount. Practically, they only need to be on the same file
> > +        * system. We check this here rather than at the ioctl layers because
> > +        * this is effectively a limitation of the fielsystem implementations,
> > +        * not so much the API itself. Further, ->remap_file_range() can be
> > +        * called from syscalls that don't have cross device copy restrictions
> > +        * (such as copy_file_range()) and so we need to catch them before we
> > +        * do any damage.
> > +        */
> > +       if (inode_in->i_sb != inode_out->i_sb)
> > +               return -EXDEV;
> > +
> >         /* Don't touch certain kinds of inodes */
> >         if (IS_IMMUTABLE(inode_out))
> >                 return -EPERM;
> > @@ -2013,14 +2026,6 @@ loff_t do_clone_file_range(struct file *file_in, loff_t pos_in,
> >         if (!S_ISREG(inode_in->i_mode) || !S_ISREG(inode_out->i_mode))
> >                 return -EINVAL;
> >
> > -       /*
> > -        * FICLONE/FICLONERANGE ioctls enforce that src and dest files are on
> > -        * the same mount. Practically, they only need to be on the same file
> > -        * system.
> > -        */
> > -       if (inode_in->i_sb != inode_out->i_sb)
> > -               return -EXDEV;
> > -
> 

I think this is sort of backwards -- the checks should stay in
do_clone_file_range, and vfs_copy_file_range should be calling that
instead of directly calling ->remap_range():

vfs_copy_file_range()
{
	file_start_write(...);
	ret = do_clone_file_range(...);
	if (ret > 0)
		return ret;
	ret = do_copy_file_range(...);
	file_end_write(...);
	return ret;
}

> That leaves {nfs42,cifs,btrfs}_remap_file_range() exposed to passing
> files not of their own fs type let alone same sb when do_clone_file_range()
> is called from ovl_copy_up_data().

...and then I think this problem goes away.

--D

> Thanks,
> Amir.
