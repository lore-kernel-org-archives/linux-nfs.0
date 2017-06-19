Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59644 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752386AbdFSHrI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Jun 2017 03:47:08 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1497711392.4684.11.camel@redhat.com>
References: <1497711392.4684.11.camel@redhat.com> <20170617095755.z623wmwgwcw76wce@thunk.org> <22bc3062-e860-5266-7a2d-9f5eff8b8559@schaufler-ca.com> <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk> <149745339478.10897.13154531822843514976.stgit@warthog.procyon.org.uk> <1402.1497472929@warthog.procyon.org.uk> <77078d8b-e8dc-5cd2-2f09-1e796d8e0e2c@schaufler-ca.com> <9029.1497709089@warthog.procyon.org.uk>
To: Jeff Layton <jlayton@redhat.com>
Cc: dhowells@redhat.com, Theodore Ts'o <tytso@mit.edu>,
        Casey Schaufler <casey@schaufler-ca.com>, mszeredi@redhat.com,
        viro@zeniv.linux.org.uk, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 08/27] VFS: Introduce the structs and doc for a filesystem context [ver #5]
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Mon, 19 Jun 2017 08:47:04 +0100
Message-ID: <25345.1497858424@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff Layton <jlayton@redhat.com> wrote:

> Do you have a reference to the discussion so I can understand the
> rationale there?

I'm afraid not - it was around 15-20 years ago, I think.  I seem to remember
the rationale being something like "because it's a stupid idea".

David
