Return-Path: <SRS0=mk5Y=RJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1638FC4360F
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Mar 2019 17:26:01 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E7E5C20842
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Mar 2019 17:26:00 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726654AbfCFR0A (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 6 Mar 2019 12:26:00 -0500
Received: from fieldses.org ([173.255.197.46]:41942 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726608AbfCFRZ7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 6 Mar 2019 12:25:59 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 5F186A9F; Wed,  6 Mar 2019 12:25:59 -0500 (EST)
Date:   Wed, 6 Mar 2019 12:25:59 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Stephen Smalley <sds@tycho.nsa.gov>
Cc:     Paul Moore <paul@paul-moore.com>,
        Eric Paris <eparis@parisplace.org>, selinux@vger.kernel.org,
        Scott Mayhew <smayhew@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] security/selinux: fix SECURITY_LSM_NATIVE_LABELS on
 reused superblock
Message-ID: <20190306172559.GC3066@fieldses.org>
References: <20190305211758.GA27437@fieldses.org>
 <ea347670-ea52-3ab6-a786-aeebff40dd0e@tycho.nsa.gov>
 <20190306153435.GF2426@fieldses.org>
 <0d7ff441-fcfe-b68f-cdf9-44a923165a2c@tycho.nsa.gov>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0d7ff441-fcfe-b68f-cdf9-44a923165a2c@tycho.nsa.gov>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Mar 06, 2019 at 11:49:36AM -0500, Stephen Smalley wrote:
> On 3/6/19 10:34 AM, J. Bruce Fields wrote:
> >On Wed, Mar 06, 2019 at 09:34:43AM -0500, Stephen Smalley wrote:
> >>I've also have another script to test context= mount handling for
> >>nfs since that should take precedence over native labels; it looks
> >>  like that might be broken again:
> >
> >Thanks for the report, I'll take a look.  That's before or after
> >applying this patch?  Assuming the former, do you have an idea how
> >recent a regression it is?
> 
> Now I'm having difficulty reproducing it entirely.  I thought on
> stock Fedora 29 (4.20.x) I was seeing the actual underlying security
> labels leaking through on files within the NFS mount despite using a
> context= mount, while correctly seeing the context mount values with
> your patch, but now I can't seem to repro.  It was this bug that
> originally motivated Scott's commit that you are further fixing
> IIUC,
> https://github.com/SELinuxProject/selinux-kernel/issues/35

For what it's worth, I can't reproduce.  (If I mount with
-overs=4.2,context=system_u:object_r:etc_t:s0 then ls -Z, I only see
system_u:object_r:etc_t:s0.)

--b.
