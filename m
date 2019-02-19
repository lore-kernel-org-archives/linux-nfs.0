Return-Path: <SRS0=cCtV=Q2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E4E6C10F00
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 23:42:21 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 75F6221479
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 23:42:21 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729984AbfBSXmU (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Feb 2019 18:42:20 -0500
Received: from mx1.redhat.com ([209.132.183.28]:35740 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726405AbfBSXmU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 19 Feb 2019 18:42:20 -0500
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id EC39E81F12;
        Tue, 19 Feb 2019 23:42:19 +0000 (UTC)
Received: from warthog.procyon.org.uk (ovpn-121-129.rdu2.redhat.com [10.10.121.129])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 6B09E19C57;
        Tue, 19 Feb 2019 23:42:15 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
        Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
        Kingdom.
        Registered in England and Wales under Company Registration No. 3798903
From:   David Howells <dhowells@redhat.com>
In-Reply-To: <8736ojybw7.fsf@xmission.com>
References: <8736ojybw7.fsf@xmission.com> <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
To:     ebiederm@xmission.com (Eric W. Biederman)
Cc:     dhowells@redhat.com, keyrings@vger.kernel.org,
        trond.myklebust@hammerspace.com, sfrench@samba.org,
        linux-security-module@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        rgb@redhat.com, linux-kernel@vger.kernel.org,
        Linux Containers <containers@lists.linux-foundation.org>,
        linux-api@vger.kernel.org
Subject: Re: [RFC PATCH 00/27] Containers and using authenticated filesystems
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <22054.1550619729.1@warthog.procyon.org.uk>
Date:   Tue, 19 Feb 2019 23:42:09 +0000
Message-ID: <22055.1550619729@warthog.procyon.org.uk>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Tue, 19 Feb 2019 23:42:20 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Eric W. Biederman <ebiederm@xmission.com> wrote:

> So you missed the main mailing lists for discussion of this kind of
> thing

Yeah, sorry about that.  I was primarily aiming it at Trond and Steve as I'd
like to consider how to go about interpolating request_key() into NFS and CIFS
so that they can make use of the key-related facilities that this makes
available with AFS.  And I was in a bit tight for time to mail it out before
having to go out.  I know, excuses... ;-)

> and the maintainer.

That would be me.  I maintain keyrings.

No one is listed in MAINTAINERS as owning namespaces.  If you feel that should
be you, please add a record.

> Looking at your description you are introducing a container id.

Yes.  For audit logging, which was why I cc'd Richard.

> You don't descibe which namespace your contianer id lives in.

It doesn't.  Not everything has to have a namespace.  As you yourself pointed
out, it should be globally unique, in which case the world is the namespace,
maybe even the universe;-).

> Without the container id living in a container this breaks
> nested containers and process migration aka CRIU.

As long as IDs are globally unique, why should break container migration?
Having a kernel container object might even make CRIU easier.

And what does "Without the container id living in a container" mean anyway?  I
have IDs attached to containers.  A container can see the IDs of its child
containers.  There should be no problem with nesting.

David
