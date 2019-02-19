Return-Path: <SRS0=cCtV=Q2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 51067C43381
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 23:24:33 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 21FF121736
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 23:24:33 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729770AbfBSXY1 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Feb 2019 18:24:27 -0500
Received: from mx1.redhat.com ([209.132.183.28]:41324 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727736AbfBSXY1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 19 Feb 2019 18:24:27 -0500
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 1B51E1E306;
        Tue, 19 Feb 2019 23:24:27 +0000 (UTC)
Received: from warthog.procyon.org.uk (ovpn-121-129.rdu2.redhat.com [10.10.121.129])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 2F8951710E;
        Tue, 19 Feb 2019 23:24:22 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
        Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
        Kingdom.
        Registered in England and Wales under Company Registration No. 3798903
From:   David Howells <dhowells@redhat.com>
In-Reply-To: <8736ojwwuq.fsf@xmission.com>
References: <8736ojwwuq.fsf@xmission.com> <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk> <155024688620.21651.16013251077091180213.stgit@warthog.procyon.org.uk>
To:     ebiederm@xmission.com (Eric W. Biederman)
Cc:     dhowells@redhat.com, keyrings@vger.kernel.org,
        trond.myklebust@hammerspace.com, sfrench@samba.org,
        linux-security-module@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        rgb@redhat.com, linux-kernel@vger.kernel.org
Subject: Re: [RFC PATCH 06/27] containers, vfs: Allow syscall dirfd arguments to take a container fd
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <20783.1550618661.1@warthog.procyon.org.uk>
Date:   Tue, 19 Feb 2019 23:24:21 +0000
Message-ID: <20784.1550618661@warthog.procyon.org.uk>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Tue, 19 Feb 2019 23:24:27 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Eric W. Biederman <ebiederm@xmission.com> wrote:

> In fact if you take care to use a path that starts with '/' the normal
> dirfd based operations work just fine.

If the path starts with '/', dirfd is ignored.  And there's an error in my
patch description - it should be:

 	mkdirat(cfd, "fred", 0755);

David
