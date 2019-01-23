Return-Path: <SRS0=PH1c=P7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC62FC282C0
	for <linux-nfs@archiver.kernel.org>; Wed, 23 Jan 2019 19:21:42 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6020221872
	for <linux-nfs@archiver.kernel.org>; Wed, 23 Jan 2019 19:21:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=hansenpartnership.com header.i=@hansenpartnership.com header.b="aFGc/tlz"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725999AbfAWTVl (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 23 Jan 2019 14:21:41 -0500
Received: from bedivere.hansenpartnership.com ([66.63.167.143]:38146 "EHLO
        bedivere.hansenpartnership.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1725996AbfAWTVl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Jan 2019 14:21:41 -0500
Received: from localhost (localhost [127.0.0.1])
        by bedivere.hansenpartnership.com (Postfix) with ESMTP id D51DF8EE27B;
        Wed, 23 Jan 2019 11:21:40 -0800 (PST)
Received: from bedivere.hansenpartnership.com ([127.0.0.1])
        by localhost (bedivere.hansenpartnership.com [127.0.0.1]) (amavisd-new, port 10024)
        with ESMTP id HkDnEBetVhDi; Wed, 23 Jan 2019 11:21:40 -0800 (PST)
Received: from [153.66.254.194] (unknown [50.35.68.20])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by bedivere.hansenpartnership.com (Postfix) with ESMTPSA id 590438EE02B;
        Wed, 23 Jan 2019 11:21:40 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=hansenpartnership.com;
        s=20151216; t=1548271300;
        bh=/SSbKYDY2QabNPaktxnHMwVebUsFiS0Lj9pNQvg6m0g=;
        h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
        b=aFGc/tlzMPspYVJM+izLS0MAQF2ts4pBX5NDkUAFsYi1G31tXUmj+ft0ITvE5xiQj
         NnxjDZUcr6Y3UXutkuwRH8E/UsPczfKuKeKHZ5waPXjnDg77ifc+AwXlemRpOITWXj
         2E0z2XXSCLKclQFp2waY/cKV0B4xw9p1V4FLsHbY=
Message-ID: <1548271299.2949.41.camel@HansenPartnership.com>
Subject: Re: [LSF/MM TOPIC] Containers and distributed filesystems
From:   James Bottomley <James.Bottomley@HansenPartnership.com>
To:     Trond Myklebust <trondmy@hammerspace.com>,
        "lsf-pc@lists.linux-foundation.org" 
        <lsf-pc@lists.linux-foundation.org>
Cc:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Date:   Wed, 23 Jan 2019 11:21:39 -0800
In-Reply-To: <d110c5e1a7c452a7da9209973bf15e1e0f021c82.camel@hammerspace.com>
References: <d110c5e1a7c452a7da9209973bf15e1e0f021c82.camel@hammerspace.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.6 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, 2019-01-23 at 18:10 +0000, Trond Myklebust wrote:
> Hi,
> 
> I'd like to propose an LSF/MM discussion around the topic of
> containers and distributed filesystems.
> 
> The background is that we have a number of decisions to make around
> dealing with namespaces when the filesystem is distributed.
> 
> On the one hand, there is the issue of which user namespace we should
> be using when putting uids/gids on the wire, or when translating into
> alternative identities (user/group name, cifs SIDs,...). There are
> two main competing proposals: the first proposal is to select the
> user namespace of the process that mounted the distributed
> filesystem. The second proposal is to (continue to) use the user
> namespace pointed to by init_nsproxy. It seems that whichever choice
> we make, we probably want to ensure that all the major distributed
> filesystems (AFS, CIFS, NFS) have consistent handling of these
> situations.

I don't think there's much disagreement among container people: most
would agree the uids on the wire should match the uids in the
container.  If you're running your remote fs via fuse in an
unprivileged container, you have no access to the kuid/kgid anyway, so
it's the way you have to run.

I think the latter comes about because most of the container
implementations still have difficulty consuming the user namespace, so
most run without it (where kuid = uid) or mis-implement it, which is
where you might get the mismatch.  Is there an actual use case where
you'd want to see the kuid at the remote end, bearing in mind that when
user namespaces are properly set up kuid is often the product of
internal subuid mapping.

> Another issue arises around the question of identifying containers
> when they are migrated. At least the NFSv4 client needs to be able to
> send a unique identifier that is preserved across container
> migration. The uts_namespace is typically insufficient for this
> purpose, since most containers don't bother to set a unique hostname.

We did have a discussion in plumbers about the container ID, but I'm
not sure it reached a useful conclusion for you (video, I'm afraid):

https://linuxplumbersconf.org/event/2/contributions/215/

> Finally, there is an issue that may be unique to NFS (in which case
> I'd be happy to see it as a hallway discussion or a BoF session)
> around preserving file state across container migrations.

If by file state, you mean the internal kernel struct file state,
doesn't CRIU already do that? or do you mean some other state?

James

