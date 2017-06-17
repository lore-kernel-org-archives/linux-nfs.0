Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from imap.thunk.org ([74.207.234.97]:38840 "EHLO imap.thunk.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752246AbdFQJ6o (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 17 Jun 2017 05:58:44 -0400
Date: Sat, 17 Jun 2017 05:57:55 -0400
From: Theodore Ts'o <tytso@mit.edu>
To: Casey Schaufler <casey@schaufler-ca.com>
Cc: David Howells <dhowells@redhat.com>, mszeredi@redhat.com,
        viro@zeniv.linux.org.uk, linux-nfs@vger.kernel.org,
        jlayton@redhat.com, linux-kernel@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 08/27] VFS: Introduce the structs and doc for a
 filesystem context [ver #5]
Message-ID: <20170617095755.z623wmwgwcw76wce@thunk.org>
References: <22bc3062-e860-5266-7a2d-9f5eff8b8559@schaufler-ca.com>
 <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk>
 <149745339478.10897.13154531822843514976.stgit@warthog.procyon.org.uk>
 <1402.1497472929@warthog.procyon.org.uk>
 <77078d8b-e8dc-5cd2-2f09-1e796d8e0e2c@schaufler-ca.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <77078d8b-e8dc-5cd2-2f09-1e796d8e0e2c@schaufler-ca.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 14, 2017 at 01:53:09PM -0700, Casey Schaufler wrote:
> On 6/14/2017 1:42 PM, David Howells wrote:
> > Casey Schaufler <casey@schaufler-ca.com> wrote:
> >
> >> Could you namespace the fields of this structure?
> >> e.g. fs_cred, fs_security
> > Linus objects to that practice.
> 
> Sigh. Never mind. Thank you.

I don't know that this is a hard and fast rule.  Struct bio uses a
"bi_" prefix (e.g., bi_error, bi_opf, bi_iter, etc.).

I find it's really helpful when I'm doing a "git grep" over the whole
tree; "git grep bi_flags" returns a much more specific and focused
results than "git grep flags".   :-)

						- Ted
