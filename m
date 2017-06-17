Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f173.google.com ([209.85.216.173]:34896 "EHLO
        mail-qt0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752944AbdFQO4f (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 17 Jun 2017 10:56:35 -0400
Received: by mail-qt0-f173.google.com with SMTP id w1so87000463qtg.2
        for <linux-nfs@vger.kernel.org>; Sat, 17 Jun 2017 07:56:34 -0700 (PDT)
Message-ID: <1497711392.4684.11.camel@redhat.com>
Subject: Re: [PATCH 08/27] VFS: Introduce the structs and doc for a
 filesystem context [ver #5]
From: Jeff Layton <jlayton@redhat.com>
To: David Howells <dhowells@redhat.com>, Theodore Ts'o <tytso@mit.edu>
Cc: Casey Schaufler <casey@schaufler-ca.com>, mszeredi@redhat.com,
        viro@zeniv.linux.org.uk, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Date: Sat, 17 Jun 2017 10:56:32 -0400
In-Reply-To: <9029.1497709089@warthog.procyon.org.uk>
References: <20170617095755.z623wmwgwcw76wce@thunk.org>
         <22bc3062-e860-5266-7a2d-9f5eff8b8559@schaufler-ca.com>
         <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk>
         <149745339478.10897.13154531822843514976.stgit@warthog.procyon.org.uk>
         <1402.1497472929@warthog.procyon.org.uk>
         <77078d8b-e8dc-5cd2-2f09-1e796d8e0e2c@schaufler-ca.com>
         <9029.1497709089@warthog.procyon.org.uk>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2017-06-17 at 15:18 +0100, David Howells wrote:
> Theodore Ts'o <tytso@mit.edu> wrote:
> 
> > I don't know that this is a hard and fast rule.  Struct bio uses a
> > "bi_" prefix (e.g., bi_error, bi_opf, bi_iter, etc.).
> 
> Linus told me to stop doing it.
> 
> David


That's a pity... I tend to like little prefixes on fields too. Trying to
find all occurrences of a symbol called "flags" in cscope is a losing
exercise.

Do you have a reference to the discussion so I can understand the
rationale there?

Thanks,
-- 
Jeff Layton <jlayton@redhat.com>
