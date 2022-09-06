Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F11A0ECAAD5
	for <linux-nfs@archiver.kernel.org>; Tue,  6 Sep 2022 12:31:01 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S240099AbiIFMbA (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 6 Sep 2022 08:31:00 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:59914 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S240121AbiIFMaZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Sep 2022 08:30:25 -0400
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 1A9BA78BED
        for <linux-nfs@vger.kernel.org>; Tue,  6 Sep 2022 05:27:15 -0700 (PDT)
Received: by fieldses.org (Postfix, from userid 2815)
        id 51A7161B2; Tue,  6 Sep 2022 08:27:14 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org 51A7161B2
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1662467234;
        bh=P2S18U++P6quSVGyKs1Xx7niQSpD5olh+3HczQ9UUUw=;
        h=Date:To:Cc:Subject:References:In-Reply-To:From:From;
        b=YWFMVYiTt55Ecm/W2wxaAcRqcDGQilgDbE2oH6QBenZ3LvBzlSbauf+kCswVePqll
         5RdJZ6aBZtQueVvFKVRTr3voYsFX1HPzFi8ZsghMC9yIrpOH2BMasaWAnr9AGTRJBJ
         76JekNIp7PP5x7u907kxZjyhCgXwNk/e2YSBSP3s=
Date:   Tue, 6 Sep 2022 08:27:14 -0400
To:     Chuck Lever III <chuck.lever@oracle.com>
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        NeilBrown <neilb@suse.de>
Subject: Re: nfs/001 failing
Message-ID: <20220906122714.GA25323@fieldses.org>
References: <BF47B6B7-CB52-4E14-94B0-E28FD5C52234@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BF47B6B7-CB52-4E14-94B0-E28FD5C52234@oracle.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org


On Mon, Sep 05, 2022 at 04:29:16PM +0000, Chuck Lever III wrote:
> Bruce reminded me I'm not the only one seeing this failure
> these days:
> 
> > nfs/001 4s ... - output mismatch (see /root/xfstests-dev/results//nfs/001.out.bad)
> >    --- tests/nfs/001.out	2019-12-20 17:34:10.569343364 -0500
> >    +++ /root/xfstests-dev/results//nfs/001.out.bad	2022-09-04 20:01:35.502462323 -0400
> >    @@ -1,2 +1,2 @@
> >     QA output created by 001
> >    -203
> >    +3
> >    ...
> 
> I'm looking at about 5 other priority bugs at the moment. Can
> someone else do a little triage?

For what it's worth, a bisect lands on
c0cbe70742f4a70893cd6e5f6b10b6e89b6db95b "NFSD: add posix ACLs to struct
nfsd_attrs".

Haven't really looked at nfs/001 except to note it does have something
to do with ACLs, so that checks out....

--b.
