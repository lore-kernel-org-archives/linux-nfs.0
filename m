Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from usa-sjc-mx-foss1.foss.arm.com ([217.140.101.70]:56872 "EHLO
        foss.arm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753345AbdHRDJo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 17 Aug 2017 23:09:44 -0400
Date: Thu, 17 Aug 2017 22:09:41 -0500
From: Kim Phillips <kim.phillips@arm.com>
To: David Howells <dhowells@redhat.com>
Cc: <mszeredi@redhat.com>, <viro@zeniv.linux.org.uk>,
        <linux-nfs@vger.kernel.org>, <jlayton@redhat.com>,
        <linux-kernel@vger.kernel.org>,
        <linux-security-module@vger.kernel.org>,
        <linux-fsdevel@vger.kernel.org>,
        perf group <linux-perf-users@vger.kernel.org>,
        Will Deacon <will.deacon@arm.com>,
        Mark Rutland <mark.rutland@arm.com>,
        Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 06/27] Provide supplementary error message facility [ver
 #5]
Message-Id: <20170817220941.8c6532b076bb0d8db60a6968@arm.com>
In-Reply-To: <149745337097.10897.6533194783327792549.stgit@warthog.procyon.org.uk>
References: <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk>
        <149745337097.10897.6533194783327792549.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 14 Jun 2017 16:16:11 +0100
David Howells <dhowells@redhat.com> wrote:

> Provide a way for the kernel to pass supplementary error messages to
> userspace.  This will make it easier for userspace, particularly in
> containers to find out what went wrong during mounts and automounts, but is
> also made available to any other syscalls that want to use it.

Hi all, I see patches 1-5 have already made it to Linus' master branch,
but I can't determine the status of this particular patch.

Assuming it's still under consideration, I'd like to attest to the
significantly higher level of user experience improvement it can give
perf users (see RFC below):  Am I taking the right approach here by
assuming this new error message facility is indeed eligible for upstream
acceptance sometime soon?

Thanks,

Kim
