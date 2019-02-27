Return-Path: <SRS0=1UK0=RC=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9BB01C43381
	for <linux-nfs@archiver.kernel.org>; Wed, 27 Feb 2019 20:48:12 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 65B17217F5
	for <linux-nfs@archiver.kernel.org>; Wed, 27 Feb 2019 20:48:12 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730139AbfB0UsL (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 27 Feb 2019 15:48:11 -0500
Received: from smtp.engr.scu.edu ([129.210.16.13]:55545 "EHLO
        yavin.engr.scu.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1729291AbfB0UsL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Feb 2019 15:48:11 -0500
Received: from unimatrix3.engr.scu.edu (unimatrix3.engr.scu.edu [129.210.16.26])
        by yavin.engr.scu.edu (8.14.4/8.14.4) with ESMTP id x1RKm8X1013730
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO);
        Wed, 27 Feb 2019 12:48:10 -0800
Received: from unimatrix3.engr.scu.edu (localhost [127.0.0.1])
        by unimatrix3.engr.scu.edu (8.14.4/8.14.4) with ESMTP id x1RKm87B027396;
        Wed, 27 Feb 2019 12:48:08 -0800
Received: from localhost (ctracy@localhost)
        by unimatrix3.engr.scu.edu (8.14.4/8.14.4/Submit) with ESMTP id x1RKm8vq027392;
        Wed, 27 Feb 2019 12:48:08 -0800
X-Authentication-Warning: unimatrix3.engr.scu.edu: ctracy owned process doing -bs
Date:   Wed, 27 Feb 2019 12:48:08 -0800 (PST)
From:   Chris Tracy <ctracy@engr.scu.edu>
To:     "J. Bruce Fields" <bfields@fieldses.org>
cc:     linux-nfs@vger.kernel.org
Subject: Re: Linux NFS v4.1 server support for dynamic slot allocation?
In-Reply-To: <20190221162740.GD23154@fieldses.org>
Message-ID: <alpine.LRH.2.21.1902271006480.23489@unimatrix3.engr.scu.edu>
References: <alpine.LRH.2.21.1902181301001.4186@unimatrix3.engr.scu.edu> <20190220171027.GA4399@fieldses.org> <alpine.LRH.2.21.1902201017450.7591@unimatrix3.engr.scu.edu> <20190221162740.GD23154@fieldses.org>
User-Agent: Alpine 2.21 (LRH 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; format=flowed; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Bruce,

 	Sorry for the delayed reply, only just now got some time to come 
back to this and test.

>> 	And in fairness, it's not like it's broken out of the box.  I'm
>> complaining about single-client read speeds being 600MB/s with NFS
>> v3/v4.0 but "only" ~440MB/s with NFS v4.1/v4.2.
>
> Out of curiosity, is your bandwidth limited by disk at this point?  If
> not it might be interesting to compare with recent upstream.

 	Yeah, the 600MB/s is disk limited in this case.

> Yep.  Here's what I've got:

 	Looks good.  Built a custom kernel with that patch and tested it 
on the NFS server.  As before, the client set 'ca_maxrequests' to 64, but 
now the server replies with 31 (instead of 10) so the session is 
established with 31[*] slots.  NFS v4.1/4.2 performance is now more or 
less equivalent to that of NFS v3/4.0 in my tests.

 	Hope this patch lands in a future RHEL 7 kernel.  :-)

 	Thanks for your time and help,

 	Chris

[*] 31 instead of 32 (NFSD_CACHE_SIZE_SLOTS_PER_SESSION) because
     'slotsize' (from 'slot_bytes()') ends up being slightly larger than
     2048. (NFSD_SLOT_CACHE_SIZE)
