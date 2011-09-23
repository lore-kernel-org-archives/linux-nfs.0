Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:44283 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751500Ab1IWQ3x (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Sep 2011 12:29:53 -0400
Received: by wwf22 with SMTP id 22so3886398wwf.1
        for <linux-nfs@vger.kernel.org>; Fri, 23 Sep 2011 09:29:52 -0700 (PDT)
In-Reply-To: <20110923162438.13574.52985.stgit@warthog.procyon.org.uk>
References: <20110923162438.13574.52985.stgit@warthog.procyon.org.uk>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 23 Sep 2011 09:29:32 -0700
Message-ID: <CA+55aFwY-De6OBtggZ-PYZpKMRv9iQ7Yg+mXUR9Ry0OyhMYaJQ@mail.gmail.com>
Subject: Re: [RFC][PATCH 0/7] Automount behaviour correction
To: David Howells <dhowells@redhat.com>
Cc: miklos@szeredi.hu, raven@themaw.net, viro@zeniv.linux.org.uk,
        jlayton@redhat.com, gregkh@suse.de, linux-nfs@vger.kernel.org,
        leonardo.lists@gmail.com
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Sep 23, 2011 at 9:24 AM, David Howells <dhowells@redhat.com> wrote:
>
> They are:

Christ, this is like the worst of all worlds. We make more code to
make more random decisions that now depend not just on random system
calls but on what filesystem those system calls act on too.

Ugh. Seriously nasty.

I did like the lchown/fchownat unification, but that was independent.

                     Linus
