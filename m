Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cam-admin0.cambridge.arm.com ([217.140.96.50]:61561 "EHLO
	cam-admin0.cambridge.arm.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752982AbaIYRPk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Sep 2014 13:15:40 -0400
Date: Thu, 25 Sep 2014 18:15:45 +0100
From: Will Deacon <will.deacon@arm.com>
To: Weston Andros Adamson <dros@primarydata.com>
Cc: Peng Tao <tao.peng@primarydata.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: WARNING at fs/nfs/write.c:743 nfs_inode_remove_request with -rc6
Message-ID: <20140925171545.GR20043@arm.com>
References: <20140923130352.GK26472@arm.com>
 <2A327753-3E60-46AC-8220-3FF0FF61F08F@primarydata.com>
 <20140923135938.GB28608@arm.com>
 <20140923145356.GD28608@arm.com>
 <5294BEB2-F20F-4E3E-BFB2-E41806A4F85A@primarydata.com>
 <FA11FBE3-42E7-46B9-B9DA-FAE368DCE96B@primarydata.com>
 <F632C770-3E3D-4FC5-BBF3-69BB1CCA8F0D@primarydata.com>
 <20140923152558.GG28608@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20140923152558.GG28608@arm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Andros,

On Tue, Sep 23, 2014 at 04:25:58PM +0100, Will Deacon wrote:
> On Tue, Sep 23, 2014 at 04:08:36PM +0100, Weston Andros Adamson wrote:
> > On Sep 23, 2014, at 11:02 AM, Weston Andros Adamson <dros@primarydata.com> wrote:
> > > Wait a second - the whole point of this extra reference (that the
> > > WARN_ON_ONCE is related to) is to handle the pass off to commit lists.
> > > 
> > > Maybe I’m just doing the wrong thing here with NFSv2!
> > > 
> > > More soon.
> > 
> > Actually, can you see if this is reproducible with NFSv3?
> 
> Just tried that, and I'm unable to trigger the problem with NFSv3.

Any more ideas? I can run with NFSv3 instead, but it's a shame to leave
v2 broken.

Will
