Return-Path: <SRS0=Vlol=SS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB5DBC10F13
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Apr 2019 19:35:49 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 729A6206BA
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Apr 2019 19:35:49 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727136AbfDPTft (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 16 Apr 2019 15:35:49 -0400
Received: from fieldses.org ([173.255.197.46]:39496 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726860AbfDPTfs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 16 Apr 2019 15:35:48 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 578511E19; Tue, 16 Apr 2019 15:35:48 -0400 (EDT)
Date:   Tue, 16 Apr 2019 15:35:48 -0400
To:     Olga Kornievskaia <aglo@umich.edu>
Cc:     linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: discuss NFS xfstest failures
Message-ID: <20190416193548.GA6662@fieldses.org>
References: <CAN-5tyHGLTFmd1t9Bn4VqbLFsnvTMJYd-dBzrn9mP-Tn7g8XVg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAN-5tyHGLTFmd1t9Bn4VqbLFsnvTMJYd-dBzrn9mP-Tn7g8XVg@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Apr 11, 2019 at 01:01:39PM -0400, Olga Kornievskaia wrote:
> Hi folks,
> 
> We have some output at the wiki --
> https://wiki.linux-nfs.org/wiki/index.php/Xfstests -- capturing a data
> point of failures (for 4.16 kernel). However, I see many more failures
> with the current (5.1-rc1). Wiki output should probably be updated
> since xfstest has now 500+ tests. I have done my best to go over the
> failures and provide some summary and comments. I'd like to see if the
> community has any comments. Anybody else would like to share their
> outputs from the xfstests that show other failures?

For what it's worth, I keep a list in testd/data/xfstests-failed with
some minimal comments:

	git://linux-nfs.org/~bfields/testd.git

Current contents appended.  As you can see there's a lot that's known
unsupported features, but also a lot that I just haven't looked into
yet.

--b.

# http://people.redhat.com/bcodding/nfs/2016/10/07/nfs_xfstest_generic/
generic/035
generic/087
generic/294
generic/306
# We don't support all fallocate modes
generic/031
generic/017
generic/062
generic/071
generic/422
generic/469
generic/499
# no fiemap
generic/032
generic/094
generic/225
generic/425
# no xattrs
generic/037
generic/337
generic/377
generic/403
generic/454
# NFSv4+ doesn't support system.posix_acl_access xattr:
generic/053
generic/105
# xfstests used to skip this, not sure why it stopped:
generic/064
# no support for fs freezing
generic/068
generic/491
# needs root?
generic/184
generic/434
# FIBMAP unsupported
generic/519
# ---- need further triage:
generic/033
generic/088 # intermittent ?
generic/089 # intermittent ?
generic/126
generic/277
generic/423
generic/426
generic/465
generic/478
# "record lock is not preserved across execve(2)"
generic/484
# need a larger device?
generic/485
generic/486
