Return-Path: <SRS0=cCtV=Q2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47972C43381
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 23:13:27 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1DF7421736
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 23:13:27 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728237AbfBSXNV (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Feb 2019 18:13:21 -0500
Received: from mx1.redhat.com ([209.132.183.28]:40435 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727091AbfBSXNV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 19 Feb 2019 18:13:21 -0500
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 5D41981127;
        Tue, 19 Feb 2019 23:13:21 +0000 (UTC)
Received: from warthog.procyon.org.uk (ovpn-121-129.rdu2.redhat.com [10.10.121.129])
        by smtp.corp.redhat.com (Postfix) with ESMTP id D99181001E7D;
        Tue, 19 Feb 2019 23:13:16 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
        Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
        Kingdom.
        Registered in England and Wales under Company Registration No. 3798903
From:   David Howells <dhowells@redhat.com>
In-Reply-To: <87h8czvhsq.fsf@xmission.com>
References: <87h8czvhsq.fsf@xmission.com> <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk> <155024685321.21651.1504201877881622756.stgit@warthog.procyon.org.uk>
To:     ebiederm@xmission.com (Eric W. Biederman)
Cc:     dhowells@redhat.com, keyrings@vger.kernel.org,
        trond.myklebust@hammerspace.com, sfrench@samba.org,
        linux-security-module@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        rgb@redhat.com, linux-kernel@vger.kernel.org
Subject: Re: [RFC PATCH 02/27] containers: Implement containers as kernel objects
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <20057.1550617996.1@warthog.procyon.org.uk>
Date:   Tue, 19 Feb 2019 23:13:16 +0000
Message-ID: <20058.1550617996@warthog.procyon.org.uk>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Tue, 19 Feb 2019 23:13:21 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Eric W. Biederman <ebiederm@xmission.com> wrote:

> > +	c->id = atomic64_inc_return(&container_id_counter);
> 
> This id is not in a namespace, and it doesn't have enough bits
> of entropy to be globally unique.   Not that 64bit is enough
> to have a chance at being globablly unique.

It's in a container, so it doesn't need to be in a namespace.  The intended
purpose is for annotating audit messages.  Globally unique wasn't particularly
in mind.  It could be turned into, say, a uuid, so that isn't really a problem
at this point.

You are right, though, it really should be globally unique as best possible -
even the one in init_container should be.  Ideally, it would look the same
inside the root container as any subcontainer.

David
