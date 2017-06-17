Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51752 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753010AbdFQOSM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 17 Jun 2017 10:18:12 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20170617095755.z623wmwgwcw76wce@thunk.org>
References: <20170617095755.z623wmwgwcw76wce@thunk.org> <22bc3062-e860-5266-7a2d-9f5eff8b8559@schaufler-ca.com> <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk> <149745339478.10897.13154531822843514976.stgit@warthog.procyon.org.uk> <1402.1497472929@warthog.procyon.org.uk> <77078d8b-e8dc-5cd2-2f09-1e796d8e0e2c@schaufler-ca.com>
To: Theodore Ts'o <tytso@mit.edu>
Cc: dhowells@redhat.com, Casey Schaufler <casey@schaufler-ca.com>,
        mszeredi@redhat.com, viro@zeniv.linux.org.uk,
        linux-nfs@vger.kernel.org, jlayton@redhat.com,
        linux-kernel@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 08/27] VFS: Introduce the structs and doc for a filesystem context [ver #5]
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Sat, 17 Jun 2017 15:18:09 +0100
Message-ID: <9029.1497709089@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Theodore Ts'o <tytso@mit.edu> wrote:

> I don't know that this is a hard and fast rule.  Struct bio uses a
> "bi_" prefix (e.g., bi_error, bi_opf, bi_iter, etc.).

Linus told me to stop doing it.

David
