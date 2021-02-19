Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9C81C433DB
	for <linux-nfs@archiver.kernel.org>; Fri, 19 Feb 2021 09:03:13 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 71BF864EAF
	for <linux-nfs@archiver.kernel.org>; Fri, 19 Feb 2021 09:03:13 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229880AbhBSJDL (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 19 Feb 2021 04:03:11 -0500
Received: from Galois.linutronix.de ([193.142.43.55]:57160 "EHLO
        galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229527AbhBSJCW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Feb 2021 04:02:22 -0500
Date:   Fri, 19 Feb 2021 10:01:38 +0100
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=linutronix.de;
        s=2020; t=1613725300;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=sYMGdW4tGOh6IMOmWxCR9Phs/sS0FjTOFTf7PQrG6oI=;
        b=gir2DZ0wP8bxN9dHORw8D3+mvJZh1CTbn86oQQ2TJl4WLkJhoYABpoCKoEzZ1VmA9++KeL
        JsuVvptcepy6skOBehV0KRVpbQYqzmGC4lkdJ5/KT9R+51sm9nE88lfTys/+NKPBrwF15E
        J6H54/iLAGX+Nm98w37D7IhYlMFGUplQM+g9Tymtfy4TIm/ORQ3sFmq6CdaHVrkGr0oNDK
        edD/7xitnMm8poVwB+0CjJp3LOfN0DY53Os+lv1HDE0NCFIfNDK++rQK+BQYpH9EaPy/mg
        qK0cZ/bOck6QSW7wXl0+BL6eWfvn+w5WF3b7B/FpD6BXCILmDV/yEKyXZVFZsA==
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=linutronix.de;
        s=2020e; t=1613725300;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=sYMGdW4tGOh6IMOmWxCR9Phs/sS0FjTOFTf7PQrG6oI=;
        b=cnhYW2LGCMeyzE+bK/JwqeT8ncoeasHmG5Ij57QrePvmlINfXPYKRoln4aGihuCrTajOqH
        CjRRuRuh7C+CzDBw==
From:   Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To:     David Howells <dhowells@redhat.com>
Cc:     Christoph Hellwig <hch@lst.de>,
        Trond Myklebust <trondmy@hammerspace.com>,
        Marc Dionne <marc.dionne@auristor.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Steve French <sfrench@samba.org>,
        Dominique Martinet <asmadeus@codewreck.org>,
        linux-cifs@vger.kernel.org, ceph-devel@vger.kernel.org,
        Jeff Layton <jlayton@redhat.com>,
        Matthew Wilcox <willy@infradead.org>, linux-cachefs@redhat.com,
        Alexander Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org,
        linux-afs@lists.infradead.org,
        v9fs-developer@lists.sourceforge.net,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Jeff Layton <jlayton@kernel.org>,
        David Wysochanski <dwysocha@redhat.com>,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 34/33] netfs: Pass flag rather than use in_softirq()
Message-ID: <20210219090138.c5w7dnf7llaw4rar@linutronix.de>
References: <20210216093044.GA24615@lst.de>
 <20210216084230.GA23669@lst.de>
 <161340385320.1303470.2392622971006879777.stgit@warthog.procyon.org.uk>
 <1376938.1613429183@warthog.procyon.org.uk>
 <1419965.1613467771@warthog.procyon.org.uk>
 <2017129.1613656956@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <2017129.1613656956@warthog.procyon.org.uk>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 2021-02-18 14:02:36 [+0000], David Howells wrote:
> How about the attached instead?

Thank you for that flag.

> David

Sebastian
