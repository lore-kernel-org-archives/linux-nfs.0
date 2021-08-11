Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DECF2C4338F
	for <linux-nfs@archiver.kernel.org>; Wed, 11 Aug 2021 20:14:43 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id C594160EB5
	for <linux-nfs@archiver.kernel.org>; Wed, 11 Aug 2021 20:14:43 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232120AbhHKUPG (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 11 Aug 2021 16:15:06 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:53708 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S232163AbhHKUPE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Aug 2021 16:15:04 -0400
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 847C7C0617A0
        for <linux-nfs@vger.kernel.org>; Wed, 11 Aug 2021 13:14:38 -0700 (PDT)
Received: by fieldses.org (Postfix, from userid 2815)
        id 7AF8C6855; Wed, 11 Aug 2021 16:14:35 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org 7AF8C6855
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1628712875;
        bh=KusfbRML7Bd5rqV8XTccel5dbFTgozfikdyi25OSt1A=;
        h=Date:To:Cc:Subject:References:In-Reply-To:From:From;
        b=x7sGwEwowSqhIxyfazf0Fw4HA7y0CODxCAoxxPynFUTickNBp4u/rQPCuvGBW6YFR
         weiRqGqM2+/sAa0IgfhtGpCWpc2iZANrzGXfzghiazHK7/in4LZOSgHgDhsNpKxtOj
         drd5yvHbg6gnQeu3vPgX29lS5c3cR8tDuec8UEIg=
Date:   Wed, 11 Aug 2021 16:14:35 -0400
To:     Chuck Lever III <chuck.lever@oracle.com>
Cc:     Olga Kornievskaia <aglo@umich.edu>,
        Bruce Fields <bfields@redhat.com>,
        Timo Rothenpieler <timo@rothenpieler.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Dai Ngo <dai.ngo@oracle.com>
Subject: Re: Spurious instability with NFSoRDMA under moderate load
Message-ID: <20210811201435.GA31574@fieldses.org>
References: <64F9A492-44B9-4057-ABA5-C8202828A8DD@oracle.com>
 <1b8a24a9-5dba-3faf-8b0a-16e728a6051c@rothenpieler.org>
 <5DD80ADC-0A4B-4D95-8CF7-29096439DE9D@oracle.com>
 <0444ca5c-e8b6-1d80-d8a5-8469daa74970@rothenpieler.org>
 <cc2f55cd-57d4-d7c3-ed83-8b81ea60d821@rothenpieler.org>
 <3AF4F6CA-8B17-4AE9-82E2-21A2B9AA0774@oracle.com>
 <CAN-5tyHNvYWd1M7sfZNV5q3Y_GZA2-DoTd=CxYvniZ1zkB5hyw@mail.gmail.com>
 <95DB2B47-F370-4787-96D9-07CE2F551AFD@oracle.com>
 <CAN-5tyGXycM1MKa=Sydoo4pP85PGLuh8yjJYsoAM3U+M1NVyCw@mail.gmail.com>
 <D417C606-9E27-431E-B80E-EE927E62A316@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <D417C606-9E27-431E-B80E-EE927E62A316@oracle.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Aug 11, 2021 at 08:01:30PM +0000, Chuck Lever III wrote:
> Probably not just CB_RECALL, but agreed, there doesn't seem to
> be any mechanism that can re-drive callback operations when the
> backchannel is replaced.

The nfsd4_queue_cb() in nfsd4_cb_release() should queue a work item
to run nfsd4_run_cb_work, which should set up another callback client if
necessary.

But I doubt this is well tested.

--b.
