Return-Path: <SRS0=ibFv=Q5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7286C43381
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 20:46:35 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AAD07206BB
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 20:46:35 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726633AbfBVUqf (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 22 Feb 2019 15:46:35 -0500
Received: from fieldses.org ([173.255.197.46]:53922 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726441AbfBVUqf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 22 Feb 2019 15:46:35 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id BF70D1E29; Fri, 22 Feb 2019 15:46:34 -0500 (EST)
Date:   Fri, 22 Feb 2019 15:46:34 -0500
To:     Charles Hedrick <hedrick@rutgers.edu>
Cc:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        steved@redhat.com
Subject: Re: bad principal used by gssd
Message-ID: <20190222204634.GC16191@fieldses.org>
References: <4F12379C-3DF3-4A9F-A2CB-087984214767@rutgers.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <4F12379C-3DF3-4A9F-A2CB-087984214767@rutgers.edu>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Feb 22, 2019 at 06:36:54PM +0000, Charles Hedrick wrote:
> Would someone please look at
> https://bugzilla.linux-nfs.org/show_bug.cgi?id=318?
> 
> If I’m logged in as hedrick but current credentials are hedrick.admin,
> I have a key ring with credentials for both hedrick and hedrick.admin.
> 
> If gssd needs to recreate its context (e.g. because the credentials
> have expired) it acquires GSSAPI credentials with NONAME. That will
> give it the current selected principal, which is hedrick.admin. Of
> course for NFS only a principal that matches the current UID can work.
> So later in the code it checks to see if the credentials it has are
> for hedrick, and fails. This is kind of silly. If you tell acquire
> what credentials you want, it will look through the keyring and pick
> the right one. So the call to acquire should specify the desired
> principal.
> 
> The bug report gives code to fix it. Because I don’t want to build my
> own gssd, my patch uses LD_PRELOAD to intercept calls, but the code
> could be put into the source in the obvious way.

No comment on whether that's the right behavior (I just don't know), but
for what it's worth I think you'll get a quicker response if it were
possible to just make it a patch against nfs-utils, and post it to the
list instead of that bugzilla.

--b.
