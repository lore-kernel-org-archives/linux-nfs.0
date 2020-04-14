Return-Path: <SRS0=4kDZ=56=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB293C352BE
	for <linux-nfs@archiver.kernel.org>; Tue, 14 Apr 2020 19:57:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id A2B722074D
	for <linux-nfs@archiver.kernel.org>; Tue, 14 Apr 2020 19:57:02 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2505274AbgDNT5A (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 14 Apr 2020 15:57:00 -0400
Received: from smtprelay0211.hostedemail.com ([216.40.44.211]:34122 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S2505250AbgDNTz5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Apr 2020 15:55:57 -0400
Received: from smtprelay.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
        by smtpgrave04.hostedemail.com (Postfix) with ESMTP id D5D591802CCB4;
        Tue, 14 Apr 2020 19:47:05 +0000 (UTC)
Received: from filter.hostedemail.com (clb03-v110.bra.tucows.net [216.40.38.60])
        by smtprelay06.hostedemail.com (Postfix) with ESMTP id 9E3611802B57F;
        Tue, 14 Apr 2020 19:47:05 +0000 (UTC)
X-Session-Marker: 6A6F6540706572636865732E636F6D
X-HE-Tag: coal59_5a1e7cc02a463
X-Filterd-Recvd-Size: 2796
Received: from XPS-9350.home (unknown [47.151.136.130])
        (Authenticated sender: joe@perches.com)
        by omf07.hostedemail.com (Postfix) with ESMTPA;
        Tue, 14 Apr 2020 19:46:59 +0000 (UTC)
Message-ID: <2a58f592879cf67b4c6b8e859ce87e1f9652902a.camel@perches.com>
Subject: Re: [PATCH v2 2/2] crypto: Remove unnecessary memzero_explicit()
From:   Joe Perches <joe@perches.com>
To:     Waiman Long <longman@redhat.com>,
        Michal =?ISO-8859-1?Q?Such=E1nek?= <msuchanek@suse.de>
Cc:     Christophe Leroy <christophe.leroy@c-s.fr>,
        Andrew Morton <akpm@linux-foundation.org>,
        David Howells <dhowells@redhat.com>,
        Jarkko Sakkinen <jarkko.sakkinen@linux.intel.com>,
        James Morris <jmorris@namei.org>,
        "Serge E. Hallyn" <serge@hallyn.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Matthew Wilcox <willy@infradead.org>,
        David Rientjes <rientjes@google.com>, linux-mm@kvack.org,
        keyrings@vger.kernel.org, linux-kernel@vger.kernel.org,
        x86@kernel.org, linux-crypto@vger.kernel.org,
        linux-s390@vger.kernel.org, linux-pm@vger.kernel.org,
        linux-stm32@st-md-mailman.stormreply.com,
        linux-arm-kernel@lists.infradead.org,
        linux-amlogic@lists.infradead.org,
        linux-mediatek@lists.infradead.org, linuxppc-dev@lists.ozlabs.org,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
        intel-wired-lan@lists.osuosl.org, linux-ppp@vger.kernel.org,
        wireguard@lists.zx2c4.com, linux-wireless@vger.kernel.org,
        devel@driverdev.osuosl.org, linux-scsi@vger.kernel.org,
        target-devel@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-fscrypt@vger.kernel.org, ecryptfs@vger.kernel.org,
        kasan-dev@googlegroups.com, linux-bluetooth@vger.kernel.org,
        linux-wpan@vger.kernel.org, linux-sctp@vger.kernel.org,
        linux-nfs@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
        cocci@systeme.lip6.fr, linux-security-module@vger.kernel.org,
        linux-integrity@vger.kernel.org
Date:   Tue, 14 Apr 2020 12:44:49 -0700
In-Reply-To: <578fe9b6-1ccd-2698-60aa-96c3f2dd2c31@redhat.com>
References: <20200413211550.8307-1-longman@redhat.com>
         <20200413222846.24240-1-longman@redhat.com>
         <eca85e0b-0af3-c43a-31e4-bd5c3f519798@c-s.fr>
         <e194a51f-a5e5-a557-c008-b08cac558572@redhat.com>
         <20200414191601.GZ25468@kitsune.suse.cz>
         <578fe9b6-1ccd-2698-60aa-96c3f2dd2c31@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
User-Agent: Evolution 3.34.1-2 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, 2020-04-14 at 15:37 -0400, Waiman Long wrote:
> OK, I can change it to clear the key length when the allocation failed
> which isn't likely.


Perhaps:

	kfree_sensitive(op->key);
	op->key = NULL;
	op->keylen = 0;

but I don't know that it impacts any possible state.


