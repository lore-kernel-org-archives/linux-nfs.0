Return-Path: <SRS0=XA/Y=QT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 823CFC282C4
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Feb 2019 15:27:01 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 52F2120863
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Feb 2019 15:27:01 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728993AbfBLP1A (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 12 Feb 2019 10:27:00 -0500
Received: from mx1.redhat.com ([209.132.183.28]:60246 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728273AbfBLP1A (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 12 Feb 2019 10:27:00 -0500
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 610D7E6A73;
        Tue, 12 Feb 2019 15:27:00 +0000 (UTC)
Received: from warthog.procyon.org.uk (ovpn-121-129.rdu2.redhat.com [10.10.121.129])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 26562648B6;
        Tue, 12 Feb 2019 15:26:58 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
        Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
        Kingdom.
        Registered in England and Wales under Company Registration No. 3798903
From:   David Howells <dhowells@redhat.com>
In-Reply-To: <20190212150323.GA19074@kroah.com>
References: <20190212150323.GA19074@kroah.com> <19914.1549970944@warthog.procyon.org.uk> <14223.1549981874@warthog.procyon.org.uk> <20190212143720.GA16380@kroah.com> <20190212144214.GA17111@kroah.com>
To:     Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc:     dhowells@redhat.com, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, mhiramat@kernel.org,
        bigeasy@linutronix.de
Subject: Re: Oops in rpc_clnt_debugfs_register() from debugfs change
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <27349.1549985217.1@warthog.procyon.org.uk>
Date:   Tue, 12 Feb 2019 15:26:57 +0000
Message-ID: <27350.1549985217@warthog.procyon.org.uk>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Tue, 12 Feb 2019 15:27:00 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Greg Kroah-Hartman <gregkh@linuxfoundation.org> wrote:

> And, if you want my larger fix that I will be sending to netdev one of
> these days, here's that one.  It includes the above patch as part of it.

That works.

Tested-by: David Howells <dhowells@redhat.com>
