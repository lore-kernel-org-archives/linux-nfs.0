Return-Path: <SRS0=08pM=S2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C61A5C282E3
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 21:54:49 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 95A2F2183E
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 21:54:49 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1732090AbfDXVyf (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 24 Apr 2019 17:54:35 -0400
Received: from mx1.redhat.com ([209.132.183.28]:36616 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1732035AbfDXVyd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 24 Apr 2019 17:54:33 -0400
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 68239E7B70;
        Wed, 24 Apr 2019 21:54:33 +0000 (UTC)
Received: from warthog.procyon.org.uk (ovpn-121-98.rdu2.redhat.com [10.10.121.98])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 2C3B319729;
        Wed, 24 Apr 2019 21:54:31 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
        Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
        Kingdom.
        Registered in England and Wales under Company Registration No. 3798903
From:   David Howells <dhowells@redhat.com>
In-Reply-To: <155612249070.8564.3179241610171819187.stgit@warthog.procyon.org.uk>
References: <155612249070.8564.3179241610171819187.stgit@warthog.procyon.org.uk> <155612240208.8564.13865046977065545591.stgit@warthog.procyon.org.uk>
Cc:     dhowells@redhat.com, ebiederm@xmission.com, netdev@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-afs@lists.infradead.org, keyrings@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        dwalsh@redhat.com, vgoyal@redhat.com
Subject: Re: [PATCH 10/11] keys: Network namespace domain tag
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <1352.1556142870.1@warthog.procyon.org.uk>
Date:   Wed, 24 Apr 2019 22:54:30 +0100
Message-ID: <1353.1556142870@warthog.procyon.org.uk>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Wed, 24 Apr 2019 21:54:33 +0000 (UTC)
To:     unlisted-recipients:; (no To-header on input)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

David Howells <dhowells@redhat.com> wrote:

> @@ -385,10 +392,20 @@ static struct net *net_alloc(void)
>  	if (!net)
>  		goto out_free;
>  
> +#ifdef CONFIG_KEYS
> +	net->key_domain = kzalloc(sizeof(struct key_tag), GFP_KERNEL);
> +	if (!net->key_domain)
> +		goto out_free_2;
> +#endif

Initialisation of net->key_domain->usage to 1 is needed here.  I've fixed that
and repushed the patches to the branch.

David
