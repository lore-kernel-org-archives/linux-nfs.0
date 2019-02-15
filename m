Return-Path: <SRS0=Mjai=QW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6268CC10F02
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 17:39:41 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3C252218FF
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 17:39:41 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728462AbfBORje convert rfc822-to-8bit (ORCPT
        <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Feb 2019 12:39:34 -0500
Received: from mx1.redhat.com ([209.132.183.28]:57708 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725939AbfBORje (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 15 Feb 2019 12:39:34 -0500
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 6BEE1C0D8047;
        Fri, 15 Feb 2019 17:39:33 +0000 (UTC)
Received: from warthog.procyon.org.uk (ovpn-121-129.rdu2.redhat.com [10.10.121.129])
        by smtp.corp.redhat.com (Postfix) with ESMTP id AF9895C3FD;
        Fri, 15 Feb 2019 17:39:20 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
        Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
        Kingdom.
        Registered in England and Wales under Company Registration No. 3798903
From:   David Howells <dhowells@redhat.com>
In-Reply-To: <758871dc-15b7-ed5c-a119-a40037309507@tycho.nsa.gov>
References: <758871dc-15b7-ed5c-a119-a40037309507@tycho.nsa.gov> <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk> <155024709026.21651.7275876165845045967.stgit@warthog.procyon.org.uk>
To:     Stephen Smalley <sds@tycho.nsa.gov>
Cc:     dhowells@redhat.com, keyrings@vger.kernel.org,
        trond.myklebust@hammerspace.com, sfrench@samba.org,
        linux-security-module@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        rgb@redhat.com, linux-kernel@vger.kernel.org,
        Paul Moore <paul@paul-moore.com>,
        SELinux <selinux@vger.kernel.org>
Subject: Re: [RFC PATCH 22/27] KEYS: Replace uid/gid/perm permissions checking with an ACL
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <32622.1550252354.1@warthog.procyon.org.uk>
Content-Transfer-Encoding: 8BIT
Date:   Fri, 15 Feb 2019 17:39:14 +0000
Message-ID: <32623.1550252354@warthog.procyon.org.uk>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Fri, 15 Feb 2019 17:39:34 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Stephen Smalley <sds@tycho.nsa.gov> wrote:

> > --- a/security/selinux/hooks.c
> > +++ b/security/selinux/hooks.c
> > @@ -6560,6 +6560,7 @@ static int selinux_key_permission(key_ref_t key_ref,
> >   {
> >   	struct key *key;
> >   	struct key_security_struct *ksec;
> > +	unsigned oldstyle_perm;
> >   	u32 sid;
> >     	/* if no specific permissions are requested, we skip the
> > @@ -6568,13 +6569,26 @@ static int selinux_key_permission(key_ref_t key_ref,
> >   	if (perm == 0)
> >   		return 0;
> >   +	oldstyle_perm = perm & (KEY_NEED_VIEW | KEY_NEED_READ | KEY_NEED_WRITE
> > |
> > +				KEY_NEED_SEARCH | KEY_NEED_LINK);
> > +	if (perm & KEY_NEED_SETSEC)
> > +		oldstyle_perm |= OLD_KEY_NEED_SETATTR;
> > +	if (perm & KEY_NEED_INVAL)
> > +		oldstyle_perm |= KEY_NEED_SEARCH;
> > +	if (perm & KEY_NEED_REVOKE && !(perm & OLD_KEY_NEED_SETATTR))
> > +		oldstyle_perm |= KEY_NEED_WRITE;
> > +	if (perm & KEY_NEED_JOIN)
> > +		oldstyle_perm |= KEY_NEED_SEARCH;
> > +	if (perm & KEY_NEED_CLEAR)
> > +		oldstyle_perm |= KEY_NEED_WRITE;
> > +
> >   	sid = cred_sid(cred);
> >     	key = key_ref_to_ptr(key_ref);
> >   	ksec = key->security;
> >     	return avc_has_perm(&selinux_state,
> > -			    sid, ksec->sid, SECCLASS_KEY, perm, NULL);
> > +			    sid, ksec->sid, SECCLASS_KEY, oldstyle_perm, NULL);
> 
> This might be ok temporarily for compatibility but we'll want to ultimately
> define the new permissions in SELinux and switch over to using them if a new
> policy capability bit is set to indicate that the policy supports them.  We
> should probably decouple the SELinux permission bits from the KEY_NEED_*
> values and explicitly map them all at the same time.

Sounds reasonable.  I should probably detach the first two ACL patches from
the set and push them separately.

David
