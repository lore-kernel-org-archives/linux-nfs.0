Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:37256 "EHLO
        out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758474AbdEWPjl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 23 May 2017 11:39:41 -0400
From: ebiederm@xmission.com (Eric W. Biederman)
To: David Howells <dhowells@redhat.com>
Cc: trondmy@primarydata.com, mszeredi@redhat.com,
        linux-nfs@vger.kernel.org, jlayton@redhat.com,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org
References: <149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
Date: Tue, 23 May 2017 10:33:01 -0500
In-Reply-To: <149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
        (David Howells's message of "Mon, 22 May 2017 17:22:26 +0100")
Message-ID: <87mva3k2qa.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: [RFC][PATCH 0/9] Make containers kernel objects
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

David Howells <dhowells@redhat.com> writes:

> Here are a set of patches to define a container object for the kernel and
> to provide some methods to create and manipulate them.

Just so this discussion has some clarity.

Nacked-by: "Eric W. Biederman" <ebiederm@xmission.com>

As a user visible entity I see nothing this container data structure
helps solve it only muddies the waters and makes things more brittle.

Embracing the complexity of namespaces head on tends to mean all of the
goofy scary semantic corner cases are visible from the first version of
the design, and so developers can't take short cuts that result in
buggy kernel code that persists for decades.  I am rather tired of
finding and fixing those.

Eric
