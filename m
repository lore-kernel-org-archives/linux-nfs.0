Return-Path: <SRS0=cCtV=Q2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5995BC43381
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 23:03:44 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2FFDB21479
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 23:03:44 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728889AbfBSXDk (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Feb 2019 18:03:40 -0500
Received: from mx1.redhat.com ([209.132.183.28]:56642 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725972AbfBSXDk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 19 Feb 2019 18:03:40 -0500
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 690D1C058CAD;
        Tue, 19 Feb 2019 23:03:39 +0000 (UTC)
Received: from warthog.procyon.org.uk (ovpn-121-129.rdu2.redhat.com [10.10.121.129])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 29D5419C57;
        Tue, 19 Feb 2019 23:03:34 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
        Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
        Kingdom.
        Registered in England and Wales under Company Registration No. 3798903
From:   David Howells <dhowells@redhat.com>
In-Reply-To: <8c95213ae0981bd7af928902fcb34d6a9dedaa6f.camel@hammerspace.com>
References: <8c95213ae0981bd7af928902fcb34d6a9dedaa6f.camel@hammerspace.com> <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk> <155024685321.21651.1504201877881622756.stgit@warthog.procyon.org.uk>
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     dhowells@redhat.com, "sfrench@samba.org" <sfrench@samba.org>,
        "keyrings@vger.kernel.org" <keyrings@vger.kernel.org>,
        "rgb@redhat.com" <rgb@redhat.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-security-module@vger.kernel.org" 
        <linux-security-module@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-cifs@vger.kernel.org" <linux-cifs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: [RFC PATCH 02/27] containers: Implement containers as kernel objects
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <19410.1550617413.1@warthog.procyon.org.uk>
Date:   Tue, 19 Feb 2019 23:03:33 +0000
Message-ID: <19411.1550617413@warthog.procyon.org.uk>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Tue, 19 Feb 2019 23:03:39 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Trond Myklebust <trondmy@hammerspace.com> wrote:

> Do we really need a new system call to set up containers? That would
> force changes to all existing orchestration software.

No, it wouldn't.  Nothing in my patches forces existing orchestration software
to change, unless it wants to use the new facilities - then it would have to
be changed anyway, right?  I will grant, though, that the extent of the change
might vary.

> Given that the main thing we want to achieve is to direct messages from
> the kernel to an appropriate handler, why not focus on adding
> functionality to do just that?

Because it's *not* just that that is added here.  There are a number of things
this patchset (and one it depends on) provides:

 (1) The ability to intercept request_key() upcalls that happen inside a
     container, filtered by operative namespace.

 (2) The ability to provide a per-container keyring that can hold keys that
     can be used inside the container without any action on behalf of the
     denizens of the container.

 (3) The ability to grant permissions to a *container* as a subject, allowing
     it and its denizens to use, but not necessarily read, modify, link or
     invalidate a key.

 (4) The ability to create superblocks inside a container with a separate
     mount namespace from outside, such that they can use the container keys,
     thereby allowing the root of a container to be on an authenticated
     filesystem.

> Is there any reason why a syscall to allow an appropriately privileged
> process to add a keyring-specific message queue to its own
> user_namespace and obtain a file descriptor to that message queue might
> not work?

Yes.  That forces the use of a new user_namespace for every container in which
you want to use any of the above features.  The user_namespace is already way
too big and intrusive a hammer as it is.

> With such an implementation, the fallback mechanism could be to walk
> back up the hierarchy of user_namespaces until a message queue is
> found, and to invoke the existing request_key mechanism if not.

That's definitely wrong.  /sbin/request-key should *not* be spawned if the key
to be instantiated is not in all the init namespaces.

I went with a container object with namespaces for a reason: initially, it was
so that the upcall could take place inside of the container's namespaces, but
now it's do that any request that doesn't match the namespaces on the
container gets rejected at the boundary - so that some daemon up the chain
doesn't try servicing a request for which it can't access the config data or
would end up talking out of the wrong NIC.

I can drop the container object part of it for the moment.

I could instead create 1-3 new namespaces:

 (1) A namespace with an upcall-interception point.

 (2) A namespace with a container keyring.

 (3) A namespace with a subject ID for use in key ACLs.

I think I should also consider adding:

 (4) A namespace with keyring names in it.  I'm leaning towards this not being
     part of user_namespace because these probably should not be visible
     between containers.

David
