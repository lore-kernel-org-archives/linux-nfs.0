Return-Path: <SRS0=Zlln=DN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C7DAC4727D
	for <linux-nfs@archiver.kernel.org>; Tue,  6 Oct 2020 15:22:26 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 91502206D4
	for <linux-nfs@archiver.kernel.org>; Tue,  6 Oct 2020 15:22:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fieldses.org header.i=@fieldses.org header.b="aqBCmYtD"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726562AbgJFPWY (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 6 Oct 2020 11:22:24 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:43766 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725906AbgJFPWY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Oct 2020 11:22:24 -0400
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 41758C061755
        for <linux-nfs@vger.kernel.org>; Tue,  6 Oct 2020 08:22:24 -0700 (PDT)
Received: by fieldses.org (Postfix, from userid 2815)
        id DFADD6EEE; Tue,  6 Oct 2020 11:22:23 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org DFADD6EEE
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1601997743;
        bh=92gPhtBE2GGdeCU/TQFGqk11rYshpFj+xrXe9w2cIr8=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=aqBCmYtDKoIu5ZOVBHviGmcqQECEHfcc48/+cqPw1X1VGbwKzvaTnhMXBP1wKb+ex
         6+n+4NrlwCtoOofNVLSbCMgeJ13hW8MK4ICe6cDwvvvRd1YB+6vVt/BEuAr9ta69Y/
         mtrjc5+Hk+AombosxA7Arc6KOczmQl21eyi/dQF8=
Date:   Tue, 6 Oct 2020 11:22:23 -0400
From:   Bruce Fields <bfields@fieldses.org>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: unsharing tcp connections from different NFS mounts
Message-ID: <20201006152223.GD28306@fieldses.org>
References: <20201006151335.GB28306@fieldses.org>
 <43CA4047-F058-4339-AD64-29453AE215D6@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <43CA4047-F058-4339-AD64-29453AE215D6@oracle.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Oct 06, 2020 at 11:20:41AM -0400, Chuck Lever wrote:
> 
> 
> > On Oct 6, 2020, at 11:13 AM, bfields@fieldses.org wrote:
> > 
> > NFSv4.1+ differs from earlier versions in that it always performs
> > trunking discovery that results in mounts to the same server sharing a
> > TCP connection.
> > 
> > It turns out this results in performance regressions for some users;
> > apparently the workload on one mount interferes with performance of
> > another mount, and they were previously able to work around the problem
> > by using different server IP addresses for the different mounts.
> > 
> > Am I overlooking some hack that would reenable the previous behavior?
> > Or would people be averse to an "-o noshareconn" option?
> 
> I thought this was what the nconnect mount option was for.

I've suggested that.  It doesn't isolate the two mounts from each other
in the same way, but I can imagine it might make it less likely that a
user on one mount will block a user on another?  I don't know, it might
depend on the details of their workload and a certain amount of luck.

--b.
