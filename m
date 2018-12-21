Return-Path: <SRS0=HAHT=O6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 798F5C43387
	for <linux-nfs@archiver.kernel.org>; Fri, 21 Dec 2018 19:08:39 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 507682190A
	for <linux-nfs@archiver.kernel.org>; Fri, 21 Dec 2018 19:08:39 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2389360AbeLUTIi (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 21 Dec 2018 14:08:38 -0500
Received: from mx1.redhat.com ([209.132.183.28]:33160 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2388931AbeLUTIi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 21 Dec 2018 14:08:38 -0500
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 1AF793B714;
        Fri, 21 Dec 2018 19:08:38 +0000 (UTC)
Received: from parsley.fieldses.org (unknown [10.17.132.205])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 00B235C1B2;
        Fri, 21 Dec 2018 19:08:37 +0000 (UTC)
Received: by parsley.fieldses.org (Postfix, from userid 2815)
        id 82E4018035E; Fri, 21 Dec 2018 14:08:37 -0500 (EST)
Date:   Fri, 21 Dec 2018 14:08:37 -0500
From:   "J. Bruce Fields" <bfields@redhat.com>
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 00/10] server-side support for "inter" SSC copy
Message-ID: <20181221190837.GB15842@parsley.fieldses.org>
References: <20181130200348.59524-1-olga.kornievskaia@gmail.com>
 <CAN-5tyGBO1CnhkEe9yPXdh4837NYsZc1fyJ4MCuMPM2eSv4C5g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAN-5tyGBO1CnhkEe9yPXdh4837NYsZc1fyJ4MCuMPM2eSv4C5g@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Fri, 21 Dec 2018 19:08:38 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Dec 20, 2018 at 01:42:27PM -0500, Olga Kornievskaia wrote:
> On Fri, Nov 30, 2018 at 3:03 PM Olga Kornievskaia
> <olga.kornievskaia@gmail.com> wrote:
> > All the patches (client inter) and this patch series is available
> > from git://linux-nfs.org/projects/aglo/linux.git under the "linux-ssc"
> > branch
> >
> 
> Bruce,
> 
> Do you have comments on this v2? Once VFS has the patches for the
> generic copy_file_range() functionality, NFS should be all set to just
> used it.

Not yet, sorry.  I probably won't be able to give it a proper review
till the second week in January, feel free to ping me again then.

--b.

> 
> > Olga Kornievskaia (10):
> >   VFS generic copy_file_range() support
> >   NFS fallback to generic_copy_file_range
> >   NFSD fill-in netloc4 structure
> >   NFSD add ca_source_server<> to COPY
> >   NFSD return nfs4_stid in nfs4_preprocess_stateid_op
> >   NFSD add COPY_NOTIFY operation
> >   NFSD check stateids against copy stateids
> >   NFSD generalize nfsd4_compound_state flag names
> >   NFSD: allow inter server COPY to have a STALE source server fh
> >   NFSD add nfs4 inter ssc to nfsd4_copy
> >
> >  fs/nfs/nfs4file.c    |   9 +-
> >  fs/nfsd/Kconfig      |  10 ++
> >  fs/nfsd/nfs4proc.c   | 406 ++++++++++++++++++++++++++++++++++++++++++++++-----
> >  fs/nfsd/nfs4state.c  | 124 ++++++++++++++--
> >  fs/nfsd/nfs4xdr.c    | 166 ++++++++++++++++++++-
> >  fs/nfsd/nfsd.h       |  32 ++++
> >  fs/nfsd/nfsfh.h      |   5 +-
> >  fs/nfsd/nfssvc.c     |   6 +
> >  fs/nfsd/state.h      |  21 ++-
> >  fs/nfsd/xdr4.h       |  37 ++++-
> >  fs/read_write.c      |  66 +++++++--
> >  include/linux/fs.h   |   7 +
> >  include/linux/nfs4.h |   1 +
> >  mm/filemap.c         |   6 +-
> >  14 files changed, 810 insertions(+), 86 deletions(-)
> >
> > --
> > 1.8.3.1
> >
