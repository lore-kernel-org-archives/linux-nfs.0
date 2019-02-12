Return-Path: <SRS0=XA/Y=QT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4ABCEC282C4
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Feb 2019 14:57:40 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 21E552075B
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Feb 2019 14:57:40 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727102AbfBLO5j (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 12 Feb 2019 09:57:39 -0500
Received: from mx1.redhat.com ([209.132.183.28]:35702 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726238AbfBLO5j (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 12 Feb 2019 09:57:39 -0500
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 416F0420B5;
        Tue, 12 Feb 2019 14:57:39 +0000 (UTC)
Received: from warthog.procyon.org.uk (ovpn-121-129.rdu2.redhat.com [10.10.121.129])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 0F7075C46B;
        Tue, 12 Feb 2019 14:57:35 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
        Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
        Kingdom.
        Registered in England and Wales under Company Registration No. 3798903
From:   David Howells <dhowells@redhat.com>
In-Reply-To: <20190212144214.GA17111@kroah.com>
References: <20190212144214.GA17111@kroah.com> <19914.1549970944@warthog.procyon.org.uk> <14223.1549981874@warthog.procyon.org.uk> <20190212143720.GA16380@kroah.com>
To:     Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc:     dhowells@redhat.com, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, mhiramat@kernel.org,
        bigeasy@linutronix.de
Subject: Re: Oops in rpc_clnt_debugfs_register() from debugfs change
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <21211.1549983454.1@warthog.procyon.org.uk>
Date:   Tue, 12 Feb 2019 14:57:34 +0000
Message-ID: <21212.1549983454@warthog.procyon.org.uk>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Tue, 12 Feb 2019 14:57:39 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Greg Kroah-Hartman <gregkh@linuxfoundation.org> wrote:

> -	if (!xprt->debugfs) {
> +	if (IS_ERR_OR_NULL(xprt->debugfs)) {

That works, though I don't much like the idea of there being an error there.

Looking in rpc_xprt_debugfs_register() there are two now-dodgy looking checks
on the result of debugfs calls.

David
