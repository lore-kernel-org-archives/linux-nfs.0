Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:48671 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756953Ab3KHPEi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Nov 2013 10:04:38 -0500
Date: Fri, 8 Nov 2013 10:04:35 -0500
To: Jeff Layton <jlayton@redhat.com>
Cc: Steve Dickson <SteveD@redhat.com>, Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Adding the nfs4_use_min_auth module parameter
Message-ID: <20131108150435.GA3533@fieldses.org>
References: <1383851364-8370-1-git-send-email-steved@redhat.com>
 <A8E8F2C4-8CB7-434E-8520-B2B53F0582D9@oracle.com>
 <527C07B4.800@RedHat.com>
 <44CA89EA-8B5E-4B83-A622-78A78F760FF1@oracle.com>
 <527CDBFC.3070903@RedHat.com>
 <20131108082202.4032f1a2@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131108082202.4032f1a2@tlielax.poochiereds.net>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 08, 2013 at 08:22:02AM -0500, Jeff Layton wrote:
> On Fri, 08 Nov 2013 07:41:32 -0500
> Steve Dickson <SteveD@redhat.com> wrote:
> > No. I think the concern here, at least my concern, is the lack of management.
> > We are forcing admins to use krb5i in lease management when its not necessary
> > and there is no way to turn it off.
> >   
> 
> I don't think that's really the case. The idea was to have the client
> attempt to use krb5i if it's available, and then to fall back to
> AUTH_SYS if it isn't. This would be *absolutely* no big deal if the
> GSSAPI upcall succeeded or failed immediately instead of requiring this
> timeout when the daemon isn't running.

I'm also still a little confused about the security model.  We discussed
it before but I can't remember if it was really resolved.

It makes sense to me as long as we insist on krb5i whenever we find a
keytab.

But my understanding was that with the current implementation it's
possible we could find a keytab, attempt the krb5i connection, and
*then* fallback silently on auth_sys if krb5i fails.  Is that right?

In that case I don't see the point of the krb5i any more: any attacker
that can spoof rpc replies can force the fallback to auth_sys.

--b.
