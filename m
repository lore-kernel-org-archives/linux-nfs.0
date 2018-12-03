Return-Path: <SRS0=4jnv=OM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54756C04EBF
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 23:58:49 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 113F92073D
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 23:58:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="zrBiIQGJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 113F92073D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726120AbeLCX6r (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 3 Dec 2018 18:58:47 -0500
Received: from aserp2120.oracle.com ([141.146.126.78]:55402 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725903AbeLCX6r (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Dec 2018 18:58:47 -0500
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
        by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wB3NwiSH073814;
        Mon, 3 Dec 2018 23:58:44 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=BuCxRIeJFK8ygjhHVTkFjEJNAPnV0XO39mKj1AjeNRM=;
 b=zrBiIQGJYqdEbh3WoaG80htolUMBrQqlcdUN58Uf3QIH8d2+2UYW2qxfdZr4tLdqkzzT
 Et9bHR/ZPfYYV1J9EYfEPHwWAFGaPcjzCHWPBvVrgtgYM8Pzl0okF+4fwuvx6N0tjYsY
 vRcsyKcGCLSEI0c3HBnPjVJNfSfQRT6C3unA/etzuPyzCpE/lY5G7UrPh652sYJKjp4g
 AQFUAg+tFq5unB7LWYFI7VByqXuyyj5EHVaYPtzGHxNrxot/LxWl5OC6sUBMwFKuk0CM
 vA1WbqPj5+eAm+mBhjdLfgxdsF5xpArQ4SUzswSc6iFXpukbXwMXgzo19ms20rtO+bnU 1w== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
        by aserp2120.oracle.com with ESMTP id 2p3j8q9fcs-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 03 Dec 2018 23:58:43 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
        by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id wB3Nwccg026849
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 3 Dec 2018 23:58:38 GMT
Received: from abhmp0019.oracle.com (abhmp0019.oracle.com [141.146.116.25])
        by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id wB3NwcqO010357;
        Mon, 3 Dec 2018 23:58:38 GMT
Received: from localhost (/10.159.157.118)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Mon, 03 Dec 2018 15:58:38 -0800
Date:   Mon, 3 Dec 2018 15:58:37 -0800
From:   "Darrick J. Wong" <darrick.wong@oracle.com>
To:     Dave Chinner <david@fromorbit.com>
Cc:     Amir Goldstein <amir73il@gmail.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-xfs <linux-xfs@vger.kernel.org>,
        Olga Kornievskaia <olga.kornievskaia@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        overlayfs <linux-unionfs@vger.kernel.org>,
        ceph-devel@vger.kernel.org, linux-cifs@vger.kernel.org
Subject: Re: [PATCH 08/11] vfs: push EXDEV check down into ->remap_file_range
Message-ID: <20181203235837.GF24487@magnolia>
References: <20181203083416.28978-1-david@fromorbit.com>
 <20181203083416.28978-9-david@fromorbit.com>
 <CAOQ4uxgwZLsO1yV37_CHaZ-O+-+-OggSP9g6m9YE57kLPc5yDw@mail.gmail.com>
 <20181203191130.GD24487@magnolia>
 <20181203233714.GL6311@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181203233714.GL6311@dastard>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9096 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=851
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1812030212
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Dec 04, 2018 at 10:37:14AM +1100, Dave Chinner wrote:
> On Mon, Dec 03, 2018 at 11:11:30AM -0800, Darrick J. Wong wrote:
> > On Mon, Dec 03, 2018 at 01:04:07PM +0200, Amir Goldstein wrote:
> > > On Mon, Dec 3, 2018 at 10:34 AM Dave Chinner <david@fromorbit.com> wrote:
> > > >
> > > > From: Dave Chinner <dchinner@redhat.com>
> > > >
> > > > before we can enable cross-device copies into copy_file_range(),
> > > > we have to ensure that ->remap_file_range() implemenations will
> > > > correctly reject attempts to do cross filesystem clones. Currently
> > > 
> > > But you only fixed remap_file_range() implemenations of xfs and ocfs2...
> > > 
> > > > these checks are done above calls to ->remap_file_range(), but
> > > > we need to drive them inwards so that we get EXDEV protection for all
> > > > callers of ->remap_file_range().
> > > >
> > > > Signed-off-by: Dave Chinner <dchinner@redhat.com>
> > > > ---
> > > >  fs/read_write.c | 21 +++++++++++++--------
> > > >  1 file changed, 13 insertions(+), 8 deletions(-)
> > > >
> > > > diff --git a/fs/read_write.c b/fs/read_write.c
> > > > index 3288db1d5f21..174cf92eea1d 100644
> > > > --- a/fs/read_write.c
> > > > +++ b/fs/read_write.c
> > > > @@ -1909,6 +1909,19 @@ int generic_remap_file_range_prep(struct file *file_in, loff_t pos_in,
> > > >         bool same_inode = (inode_in == inode_out);
> > > >         int ret;
> > > >
> > > > +       /*
> > > > +        * FICLONE/FICLONERANGE ioctls enforce that src and dest files are on
> > > > +        * the same mount. Practically, they only need to be on the same file
> > > > +        * system. We check this here rather than at the ioctl layers because
> > > > +        * this is effectively a limitation of the fielsystem implementations,
> > > > +        * not so much the API itself. Further, ->remap_file_range() can be
> > > > +        * called from syscalls that don't have cross device copy restrictions
> > > > +        * (such as copy_file_range()) and so we need to catch them before we
> > > > +        * do any damage.
> > > > +        */
> > > > +       if (inode_in->i_sb != inode_out->i_sb)
> > > > +               return -EXDEV;
> > > > +
> > > >         /* Don't touch certain kinds of inodes */
> > > >         if (IS_IMMUTABLE(inode_out))
> > > >                 return -EPERM;
> > > > @@ -2013,14 +2026,6 @@ loff_t do_clone_file_range(struct file *file_in, loff_t pos_in,
> > > >         if (!S_ISREG(inode_in->i_mode) || !S_ISREG(inode_out->i_mode))
> > > >                 return -EINVAL;
> > > >
> > > > -       /*
> > > > -        * FICLONE/FICLONERANGE ioctls enforce that src and dest files are on
> > > > -        * the same mount. Practically, they only need to be on the same file
> > > > -        * system.
> > > > -        */
> > > > -       if (inode_in->i_sb != inode_out->i_sb)
> > > > -               return -EXDEV;
> > > > -
> > > 
> > 
> > I think this is sort of backwards -- the checks should stay in
> > do_clone_file_range, and vfs_copy_file_range should be calling that
> > instead of directly calling ->remap_range():
> > 
> > vfs_copy_file_range()
> > {
> > 	file_start_write(...);
> > 	ret = do_clone_file_range(...);
> > 	if (ret > 0)
> > 		return ret;
> > 	ret = do_copy_file_range(...);
> > 	file_end_write(...);
> > 	return ret;
> > }
> 
> I'm already confused by the way we weave in and out of "vfs_/do_*"
> functions, and this just makes it worse.
> 
> Just what the hell is supposed to be in a "vfs_" prefixed function,
> and why the hell is it considered a "vfs" level function if we then
> export it's internal functions for individual filesystems to use?

I /think/ vfs_ functions are file_start_write()/file_end_write()
wrappers around a similarly named function that lacks the freeze
protection??

(AFAICT Amir made that split so that overlayfs could use these
functions, though I do not know if everything vfs_ was made that way
/specifically/ for overlayfs or if that's the way things have been and
ovlfs simply takes advantage of it...)

Guhhh, none of this is documented......

--D

> Cheers,
> 
> Dave.
> -- 
> Dave Chinner
> david@fromorbit.com
