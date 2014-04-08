Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:17771 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757058AbaDHNtK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Apr 2014 09:49:10 -0400
Date: Tue, 8 Apr 2014 09:49:03 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <androsadamson@gmail.com>,
        chuck.lever@oracle.com, trond.myklebust@primarydata.com
Subject: Re: v4.0 CB_COMPOUND authentication failures
Message-ID: <20140408094903.33e42de2@tlielax.poochiereds.net>
In-Reply-To: <20140408123501.GA3532@fieldses.org>
References: <20140408082140.340c1328@tlielax.poochiereds.net>
	<20140408123501.GA3532@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 8 Apr 2014 08:35:01 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Tue, Apr 08, 2014 at 08:21:40AM -0400, Jeff Layton wrote:
> > I've recently been hunting down some problems with delegation handling
> > and have run across a problem with the client authenticates CB_COMPOUND
> > requests. I could use some advice on how best to fix it.
> > 
> > Specifically, check_gss_callback_principal() tries to look up the
> > callback client and then tries to compare the ticket in it against the
> > clp->cl_hostname:
> > 
> >         /* Expect a GSS_C_NT_HOSTBASED_NAME like "nfs@serverhostname" */
> > 
> >         if (memcmp(p, "nfs@", 4) != 0)
> >                 return 0;
> >         p += 4;
> >         if (strcmp(p, clp->cl_hostname) != 0)
> >                 return 0;
> >         return 1;
> > 
> > The problem is that there is no guarantee that those hostnames will be
> > the same. If, for instance, I mount "foo:/" and the SPN is
> > "nfs/foo.bar.baz" that strcmp will return true, and the CB_COMPOUND
> > request will get tossed out [1]. Ditto if I happen to mount a CNAME of the
> > server.
> 
> It sounds like a bug to me that the mount is succeeding without the name
> matching.
> 
> The security provided by krb5 is much weaker if we don't check that the
> name provided on the commandline matches what the server authenticates
> as.
> 

The logic in gssd for this is pretty awful.

It will basically trust DNS if there is no '.' in the hostname that was
used at mount time. That'll make it take the address and
reverse-resolve it.

We could add yet another band-aid and make it so that DNS is never
trusted. I'll note that for cifs, we took that route. You have to mount
the canonical name of the server in order to use krb5.


> > Now that we try to use krb5 on the callback channel even when sec=sys
> > is specified, this is very problematic.
> 
> And similarly I think the attempt to opportunistically use krb5 for
> state management should fail and fall back on auth_sys if the server's
> name doesn't match.
> 

Like Trond pointed out, the problem is that gssd doesn't give us that
info currently. We could change it to do that of course, but that
basically means revving the downcall.

> > I think that the ideal thing would be to stash the SPN that we use to
> > do the SETCLIENTID call and use that in the comparison above.
> > Unfortunately, the rpc_cred doesn't really seem to carry this info and
> > I don't see where we get enough information in the rpc.gssd downcall to
> > figure out what that SPN should be.
> > 
> > Anyone have thoughts or should we just remove the above check until we
> > come up with a better way to do this?
> > 
> > [1]: there's another bug that can cause the client to send a bogus
> >      reply instead of dropping the request as intended, but that's
> >      relatively simple to fix.
> 
> So I believe the matching really is a requirement and that it would be
> wrong to weaken it.
> 
> It sounds like there's also a server bug here if it's giving out
> delegations to a client that isn't responding to callbacks.
> 

The server uses CB_NULL requests to probe the callback port, and those
aren't affected by this problem. Worse, since CB_NULL requests don't
even contain the callback_ident, we can't even use them to hook up the
nfs_client with the SPN used in them.

-- 
Jeff Layton <jlayton@redhat.com>
