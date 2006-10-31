From: "Jesper Juhl" <jesper.juhl@gmail.com>
Subject: Re: [PATCH] NFS: nfsaclsvc_encode_getaclres() - Fix potential NULL deref and tiny optimization.
Date: Tue, 31 Oct 2006 17:40:21 +0100
Message-ID: <9a8748490610310840w28d44a88xd1db60b155c03f52@mail.gmail.com>
References: <200610272316.47089.jesper.juhl@gmail.com>
	 <Pine.LNX.4.64N.0610271443500.31179@attu2.cs.washington.edu>
	 <200610280001.49272.jesper.juhl@gmail.com>
	 <200610311726.00411.agruen@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: "David Rientjes" <rientjes@cs.washington.edu>,
	linux-kernel@vger.kernel.org, "Neil Brown" <neilb@cse.unsw.edu.au>,
	nfs@lists.sourceforge.net, "Andrew Morton" <akpm@osdl.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1423547AbWJaQkY@vger.kernel.org>
To: "Andreas Gruenbacher" <agruen@suse.de>
In-Reply-To: <200610311726.00411.agruen@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On 31/10/06, Andreas Gruenbacher <agruen@suse.de> wrote:
> On Saturday 28 October 2006 00:01, Jesper Juhl wrote:
> > > > 3) There are two locations in the function where we may return before
> > > > we use the value of the variable 'w', but we compute it at the very top
> > > > of the function. So in the case where we return early we have wasted a
> > > > few cycles computing a value that was never used.
>
> Computing w later in the function is fine.
>
> > > w should be an unsigned int.
> >
> > Makes sense.
>
> No, this breaks the while loop further below: with an unsigned int, the loop
> counter underflows and wraps.
>
Whoops. OK.

> Please fix this identically in fs/nfsd/nfs2acl.c and fs/nfsd/nfs3acl.c.
>
Sure thing, expect patches later this evening.

BTW: I posted an add-on patch on top of my first one - apart from the
"make w unsigned" bit, is the rest of that OK?

-- 
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html
