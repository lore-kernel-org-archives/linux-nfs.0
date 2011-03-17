Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:44365 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755712Ab1CQWy7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Mar 2011 18:54:59 -0400
Date: Thu, 17 Mar 2011 18:54:58 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 15/17] CLNT: test lock before RECLAIM_COMPLETE
Message-ID: <20110317225458.GF31845@fieldses.org>
References: <4D6DE26C.3010103@cn.fujitsu.com>
 <4D6DE55F.6040205@cn.fujitsu.com>
 <20110314192733.GD25442@fieldses.org>
 <4D7ED7BE.70400@cn.fujitsu.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D7ED7BE.70400@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Mar 15, 2011 at 11:06:38AM +0800, Mi Jinlong wrote:
> 
> 
> J. Bruce Fields:
> > On Wed, Mar 02, 2011 at 02:36:15PM +0800, Mi Jinlong wrote:
> >> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
> > 
> > I'm getting failures I don't understand on these reclaim complete tests
> > too.
> 
>   Maybe there are some problem I have missing. 
> 
>   If testing reclaim-complete, we should restart server's NFS service.
>   I think those tests about reclaim-complete need some fix.

Probably so.

Also:

> >> +    oseqid = res.resarray[2].stateid
> >> +    cfh = res.resarray[3].object

This has the same problem as SEQ14, I suspect.

In general I'm nervous about grabbing results directly out of the
resarray.  We shouldn't have to know so much about the structure of a
compound that some other part of the code constructed.

--b.

> >> +    owner = open_owner4(0, "My Open Owner")
> >> +    otlowner = open_to_lock_owner4(0, oseqid, 0, owner)
> >> +    lowner = locker4(TRUE, otlowner)
> >> +
> >> +    res = sess.compound([op.putfh(cfh), op.lock(READ_LT, FALSE, 0, 1, lowner)])
> >> +    check(res, NFS4ERR_NO_GRACE)
> >> -- 
> >> 1.7.4.1
> >>
> >>
> >>
> > 
> 
