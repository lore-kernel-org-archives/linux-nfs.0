Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:18503 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754525Ab1ILVKx convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Sep 2011 17:10:53 -0400
Subject: Re: [PATCH] nfs: fix inifinite loop at nfs4_layoutcommit_release
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Benny Halevy <bhalevy@tonian.com>
Cc: Peng Tao <bergwolf@gmail.com>, tao.peng@emc.com, gusev.vitaliy@nexenta.com,
        gusev.vitaliy@gmail.com, linux-nfs@vger.kernel.org
Date: Mon, 12 Sep 2011 17:10:51 -0400
In-Reply-To: <4E6E6C3B.2040605@tonian.com>
References: <1314512558-16912-1-git-send-email-gusev.vitaliy@nexenta.com>
	 <1315337382.16274.7.camel@lade.trondhjem.org> <4E669B21.30006@nexenta.com>
	 <1315348373.19556.22.camel@lade.trondhjem.org>
	 <F19688880B763E40B28B2B462677FBF805C3299CA3@MX09A.corp.emc.com>
	 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B0ED3DF@SACMVEXC2-PRD.hq.netapp.com>
	 <CA+a=Yy71JNEgG4q0e69BWEjxqh71CTcfise6KKTyYkXGUM68Tw@mail.gmail.com>
	 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B0ED4C8@SACMVEXC2-PRD.hq.netapp.com>
	 <F19688880B763E40B28B2B462677FBF805C3299D2F@MX09A.corp.emc.com>
	 <1315592430.17611.15.camel@lade.trondhjem.org>
	 <4E6B0E48.7050208@tonian.com>
	 <CA+a=Yy5fMHPcSU4EoSo1uiOUCfi8vjRVPAjEYGZ+M00CwZ8Z9g@mail.gmail.com>
	 <4E6E6C3B.2040605@tonian.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1315861851.8350.11.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2011-09-12 at 13:31 -0700, Benny Halevy wrote: 
> On 2011-09-12 07:56, Peng Tao wrote:
> >> The layout segments are not really in use while in LAYOUTCOMMIT.
> >> We only need to get the stateid right with respect to concurrent layout recalls.
> > LAYOUTCOMMIT takes lseg reference to mark them as in use so that
> > layoutrecall cannot free them.
> > 
> 
> And if layoutrecall would have freed layout segments during layoutcommit,
> what is your specific concern?

That layoutcommit is supposed to return NFS4ERR_BAD_LAYOUT in that case
according to section 18.42.3 of RFC5661. I can't find anything in the
errata that changes that requirement.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

