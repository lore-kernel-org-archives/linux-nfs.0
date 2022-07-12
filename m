Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41B84C43334
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Jul 2022 14:17:24 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S233071AbiGLORX (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 12 Jul 2022 10:17:23 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:60444 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229683AbiGLOQ6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Jul 2022 10:16:58 -0400
Received: from out03.mta.xmission.com (out03.mta.xmission.com [166.70.13.233])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id D641A72EF1;
        Tue, 12 Jul 2022 07:16:57 -0700 (PDT)
Received: from in02.mta.xmission.com ([166.70.13.52]:52280)
        by out03.mta.xmission.com with esmtps  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
        (Exim 4.93)
        (envelope-from <ebiederm@xmission.com>)
        id 1oBGh6-00HHYh-JG; Tue, 12 Jul 2022 08:16:56 -0600
Received: from ip68-227-174-4.om.om.cox.net ([68.227.174.4]:44978 helo=email.froward.int.ebiederm.org.xmission.com)
        by in02.mta.xmission.com with esmtpsa  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
        (Exim 4.93)
        (envelope-from <ebiederm@xmission.com>)
        id 1oBGh5-00Dcz6-D8; Tue, 12 Jul 2022 08:16:56 -0600
From:   "Eric W. Biederman" <ebiederm@xmission.com>
To:     Benjamin Coddington <bcodding@redhat.com>
Cc:     David Howells <dhowells@redhat.com>, linux-kernel@vger.kernel.org,
        Ian Kent <raven@themaw.net>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Linux Containers <containers@lists.linux.dev>
References: <cover.1657624639.git.bcodding@redhat.com>
Date:   Tue, 12 Jul 2022 09:16:31 -0500
In-Reply-To: <cover.1657624639.git.bcodding@redhat.com> (Benjamin Coddington's
        message of "Tue, 12 Jul 2022 08:35:19 -0400")
Message-ID: <875yk25scg.fsf@email.froward.int.ebiederm.org>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/27.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
X-XM-SPF: eid=1oBGh5-00Dcz6-D8;;;mid=<875yk25scg.fsf@email.froward.int.ebiederm.org>;;;hst=in02.mta.xmission.com;;;ip=68.227.174.4;;;frm=ebiederm@xmission.com;;;spf=softfail
X-XM-AID: U2FsdGVkX19JAGcodrl2XslC9iLjx2+NewTf7WBi7Ko=
X-SA-Exim-Connect-IP: 68.227.174.4
X-SA-Exim-Mail-From: ebiederm@xmission.com
Subject: Re: [RFC PATCH 0/2] Keyagents: another call_usermodehelper approach
 for namespaces
X-SA-Exim-Version: 4.2.1 (built Sat, 08 Feb 2020 21:53:50 +0000)
X-SA-Exim-Scanned: Yes (on in02.mta.xmission.com)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org


Adding the containers list to the discussion so more interested people
have a chance of seeing this.

Benjamin Coddington <bcodding@redhat.com> writes:

> A persistent unsolved problem exists: how can the kernel find and/or create
> the appropriate "container" within which to execute a userspace program to
> construct keys or satisfy users of call_usermodehelper()?
>
> I believe the latest serious attempt to solve this problem was David's "Make
> containers kernel objects":
> https://lore.kernel.org/lkml/149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk/
>
> Over in NFS' space, we've most recently pondered this issue while looking at
> ways to pass a kernel socket to userspace in order to handle TLS events:
> https://lore.kernel.org/linux-nfs/E2BF9CFF-9361-400B-BDEE-CF5E0AFDCA63@redhat.com/
>
> The problem is that containers are not kernel objects, rather a collection
> of namespaces, cgroups, etc.  Attempts at making the kernel aware of
> containers have been mired in discussion and problems.  It has been
> suggested that the best representation of a "container" from the kernel's
> perspective is a process.
>
> Keyagents are processes represented by a key.  If a keyagent's key is linked
> to a session_keyring, it can be sent a realtime signal when a calling
> process requests a matching key_type.  That signal will dispatch the process
> to construct the desired key within the keyagent process context.  Keyagents
> are similar to ssh-agents.  To use a keyagent, one must execute a keyagent
> process in the desired context, and then link the keyagent's key onto other
> process' session_keyrings.
>
> This method of linking keyagent keys to session_keyrings can be used to
> construct the various mappings of callers to keyagents that containers may
> need.  A single keyagent process can answer request-key upcalls across
> container boundaries, or upcalls can be restricted to specific containers.
>
> I'm aware that building on realtime signals may not be a popular choice, but
> using realtime signals makes this work simple and ensures delivery.  Realtime
> signals are able to convey everything needed to construct keys in userspace:
> the under-construction key's serial number.
>
> This work is not complete; it has security implications, it needs
> documentation, it has not been reviewed by anyone.  Thanks for reading this
> RFC.  I wish to collect criticism and validate this approach.

At a high level I do agree that we need to send a message to a userspace
process and that message should contain enough information to start the
user mode helper.

Then a daemon or possibly the container init can receive the message
and dispatch the user mode helper.

Fundamentally that design solves all of the container issues, and I
think solves a few of the user mode helper issues as well.

The challenge with this design is that it requires someone standing up a
daemon to receive the messages and call a user mode helper to retain
compatibility with current systems.



I would prefer to see a file descriptor rather than a signal used to
deliver the message.  Signals suck for many many reasons and a file
descriptor based notification potentially can be much simpler.

One of those many reasons is that by not following the common pattern
for filling in kernel_siginfo you have left uninitialized padding in
your structure that will be copied to userspace thus creating a kernel
information leak.  Similarly your code doesn't fill in about half the
fields that are present in the siginfo union for the _rt case.


I think a file descriptor based design could additionally address the
back and forth your design needs with keys to figure out what event has
happened and what user mode helper to invoke.



Ideally I would also like to see a design less tied to keys.  So that we
could use this for the other user mode helper cases as well.   That said
solving request_key appears to be the truly important part, there aren't
many other user mode helpers.  Still it would be nice if in theory the
design could be used to dispatch the coredump helper as well.

Eric
