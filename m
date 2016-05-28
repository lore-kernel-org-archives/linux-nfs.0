Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f42.google.com ([209.85.214.42]:36091 "EHLO
	mail-it0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752022AbcE1AiL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 May 2016 20:38:11 -0400
Received: by mail-it0-f42.google.com with SMTP id e62so6048709ita.1
        for <linux-nfs@vger.kernel.org>; Fri, 27 May 2016 17:38:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <19769bfc-efc7-495f-9574-f771236a9765@default>
References: <19769bfc-efc7-495f-9574-f771236a9765@default>
Date: Fri, 27 May 2016 17:30:18 -0700
Message-ID: <CA+55aFzxNC0cryH4Cw660NXR2GyZ+A4qQnqRjpPf=uc=G4Wciw@mail.gmail.com>
Subject: Re: [GIT PULL] Please pull NFS client changes for Linux 4.7
From: Linus Torvalds <torvalds@linux-foundation.org>
To: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 27, 2016 at 5:17 PM, Boris Ostrovsky
<boris.ostrovsky@oracle.com> wrote:
>
> It does fix it.

Ok, I've committed that in my tree, will do my usual build test and push out.

> This is not the first time we've hit this and people have always been
> changing code to initialize fields in execution path (and I didn't fix
> it here myself because I wasn't sure where to do that).  I guess we
> could have been just adding braces all along.

Well, adding the braces also requires that you get the *order* of the
member initialization right, since the braces will be unnamed.

In this case, the unnamed union was the first member, so the trivial
patch worked, but that's not always the case.

In fact, in this case, I think an alternate and possibly better fix
would have been to just remove the ".data = { 0 }" initializer
entirely, since in its absence it would have been initialized to zero
anyway.

But since you already tested my uglier "just add a brace like the
error message suggests" that's the one I'll be committing.

It's a fairly annoying failure of older compilers, exactly because
people with newer compilers won't even realize that they are causing
problems.

               Linus
