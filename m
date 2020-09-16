Return-Path: <SRS0=3Pxj=CZ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41BC5C43461
	for <linux-nfs@archiver.kernel.org>; Wed, 16 Sep 2020 00:34:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 0DF5420739
	for <linux-nfs@archiver.kernel.org>; Wed, 16 Sep 2020 00:34:10 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726783AbgIPAeF (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 15 Sep 2020 20:34:05 -0400
Received: from smtprelay0130.hostedemail.com ([216.40.44.130]:55218 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1726661AbgIPAd5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Sep 2020 20:33:57 -0400
Received: from filter.hostedemail.com (clb03-v110.bra.tucows.net [216.40.38.60])
        by smtprelay03.hostedemail.com (Postfix) with ESMTP id 3DD4D837F24C;
        Wed, 16 Sep 2020 00:33:55 +0000 (UTC)
X-Session-Marker: 6A6F6540706572636865732E636F6D
X-HE-Tag: corn68_1c0caec27115
X-Filterd-Recvd-Size: 3131
Received: from XPS-9350.home (unknown [47.151.133.149])
        (Authenticated sender: joe@perches.com)
        by omf09.hostedemail.com (Postfix) with ESMTPA;
        Wed, 16 Sep 2020 00:33:53 +0000 (UTC)
Message-ID: <2786f88508b99c8e1ebee62ea955c4026368c878.camel@perches.com>
Subject: Re: [PATCH] nfs: remove incorrect fallthrough label
From:   Joe Perches <joe@perches.com>
To:     "Gustavo A. R. Silva" <gustavo@embeddedor.com>,
        Nick Desaulniers <ndesaulniers@google.com>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc:     Nathan Chancellor <natechancellor@gmail.com>,
        Miaohe Lin <linmiaohe@huawei.com>,
        Hongxiang Lou <louhongxiang@huawei.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        clang-built-linux@googlegroups.com
Date:   Tue, 15 Sep 2020 17:33:52 -0700
In-Reply-To: <de27c65b-ae7d-a2ba-3ab8-717c10f297c3@embeddedor.com>
References: <20200915225751.274531-1-ndesaulniers@google.com>
         <9441ed0f247d0cac6e85f3847e1b4c32a199dd8f.camel@perches.com>
         <55f1ff08-fc3c-62ed-429d-c9ae285a3a49@embeddedor.com>
         <de27c65b-ae7d-a2ba-3ab8-717c10f297c3@embeddedor.com>
Content-Type: text/plain; charset="ISO-8859-1"
User-Agent: Evolution 3.36.4-0ubuntu1 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, 2020-09-15 at 19:01 -0500, Gustavo A. R. Silva wrote:
> 
> On 9/15/20 18:51, Gustavo A. R. Silva wrote:
> > 
> > On 9/15/20 18:29, Joe Perches wrote:
> > > On Tue, 2020-09-15 at 15:57 -0700, Nick Desaulniers wrote:
> > > > There is no case after the default from which to fallthrough to. Clang
> > > > will error in this case (unhelpfully without context, see link below)
> > > > and GCC will with -Wswitch-unreachable.
> > > > 
> > > > The previous commit should have just removed the comment.
> > > []
> > > > diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> > > []
> > > > @@ -889,7 +889,6 @@ static struct nfs_server *nfs_try_mount_request(struct fs_context *fc)
> > > >  		default:
> > > >  			if (rpcauth_get_gssinfo(flavor, &info) != 0)
> > > >  				continue;
> > > > -			fallthrough;
> > > 
> > > My preference would be to convert the fallthrough
> > > to a break here so if someone ever adds another
> > > label after default: for any reason, the code would
> > > still work as expected.
> > 
> > I agree with Joe.
> 
> Actually, this is part of the work I plan to do to enable -Wimplicit-fallthrough
> for Clang: audit every place where we could use a break instead of a fallthrough.
> 
> I'm on vacation this week. So, I'll get back to this next week.

Nice, thanks Gustavo.

As part of that work, perhaps you could also find all the

	switch (<foo>) {
	[cases...]
		[code...];
		break;

	default:
		[code...]
		(no break)
	}

uawa where the last label/default block does _not_ have a break
statement and add one too.

Also see:  https://gcc.gnu.org/bugzilla/show_bug.cgi?id=91432

gcc does _not_ warn on

	switch (<foo>) {
	case BAR:
		[code];
		(no fallthrough)

	case BAZ:
		break;
	}

It might be good to add the appropriate fallthrough
for those case blocks too.


