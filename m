Return-Path: <SRS0=l1yb=A6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C4525C433E2
	for <linux-nfs@archiver.kernel.org>; Sun, 19 Jul 2020 18:13:04 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id B280A20684
	for <linux-nfs@archiver.kernel.org>; Sun, 19 Jul 2020 18:13:04 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726389AbgGSSNE (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 19 Jul 2020 14:13:04 -0400
Received: from out02.mta.xmission.com ([166.70.13.232]:52428 "EHLO
        out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726009AbgGSSND (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 19 Jul 2020 14:13:03 -0400
Received: from in01.mta.xmission.com ([166.70.13.51])
        by out02.mta.xmission.com with esmtps (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128)
        (Exim 4.90_1)
        (envelope-from <ebiederm@xmission.com>)
        id 1jxDo4-0006mh-Ph; Sun, 19 Jul 2020 12:13:00 -0600
Received: from ip68-227-160-95.om.om.cox.net ([68.227.160.95] helo=x220.xmission.com)
        by in01.mta.xmission.com with esmtpsa (TLS1.2:ECDHE_RSA_AES_256_GCM_SHA384:256)
        (Exim 4.87)
        (envelope-from <ebiederm@xmission.com>)
        id 1jxDo3-0004e5-LR; Sun, 19 Jul 2020 12:13:00 -0600
From:   ebiederm@xmission.com (Eric W. Biederman)
To:     David Howells <dhowells@redhat.com>
Cc:     Stephen Smalley <stephen.smalley.work@gmail.com>,
        Casey Schaufler <casey@schaufler-ca.com>,
        keyrings@vger.kernel.org,
        Jarkko Sakkinen <jarkko.sakkinen@linux.intel.com>,
        Paul Moore <paul@paul-moore.com>, selinux@vger.kernel.org,
        jlayton@redhat.com, christian@brauner.io,
        linux-afs@lists.infradead.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-api@vger.kernel.org,
        linux-fsdevel@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        containers@lists.linux-foundation.org,
        Linus Torvalds <torvalds@linux-foundation.org>
References: <159493167778.3249370.8145886688150701997.stgit@warthog.procyon.org.uk>
Date:   Sun, 19 Jul 2020 13:10:04 -0500
In-Reply-To: <159493167778.3249370.8145886688150701997.stgit@warthog.procyon.org.uk>
        (David Howells's message of "Thu, 16 Jul 2020 21:34:37 +0100")
Message-ID: <87tuy3nzpf.fsf@x220.int.ebiederm.org>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
X-XM-SPF: eid=1jxDo3-0004e5-LR;;;mid=<87tuy3nzpf.fsf@x220.int.ebiederm.org>;;;hst=in01.mta.xmission.com;;;ip=68.227.160.95;;;frm=ebiederm@xmission.com;;;spf=neutral
X-XM-AID: U2FsdGVkX18n0FB3g8mviWS9DVa7xa6vqYpzduK73Jk=
X-SA-Exim-Connect-IP: 68.227.160.95
X-SA-Exim-Mail-From: ebiederm@xmission.com
Subject: Re: [RFC PATCH 0/5] keys: Security changes, ACLs and Container keyring
X-SA-Exim-Version: 4.2.1 (built Thu, 05 May 2016 13:38:54 -0600)
X-SA-Exim-Scanned: Yes (on in01.mta.xmission.com)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

David Howells <dhowells@redhat.com> writes:

> Here are some patches to provide some security changes and some container
> support:

Nacked-by: "Eric W. Biederman" <ebiederm@xmission.com>

There remain unfixed security issues in the new mount api.   Those need
to get fixed before it is even worth anyones time reviewing new code.

Those issues came up in the review.  I successfully demonstrated how to
address the security issues in the new mount api before the code was
merged.  Yet the code was merged with the security issues present,
and I have not seem those issues addressed.

So far I have had to rewrite two filesystems because of bugs in the
mount API.

Enough is enough.  Let's get the what has already been merged sorted
out before we had more.

Eric
