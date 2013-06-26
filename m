Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:42987 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751269Ab3FZP3K (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Jun 2013 11:29:10 -0400
Date: Wed, 26 Jun 2013 11:29:07 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] nfs: allow NFSv3 to fall back to using AUTH_UNIX
 automatically if available
Message-ID: <20130626112907.73138046@tlielax.poochiereds.net>
In-Reply-To: <1EEAEFAF-F8B9-41AE-8CC9-459F9ADDCD12@oracle.com>
References: <1372257363-28148-1-git-send-email-jlayton@redhat.com>
	<1372257363-28148-3-git-send-email-jlayton@redhat.com>
	<1EEAEFAF-F8B9-41AE-8CC9-459F9ADDCD12@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 26 Jun 2013 11:15:08 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On Jun 26, 2013, at 10:36 AM, Jeff Layton <jlayton@redhat.com> wrote:
> 
> > Currently, when using NFSv3 the mount will fail if the server happens to
> > have AUTH_GSS flavors in the returned authlist before AUTH_UNIX. This
> > seems to have been a deliberate change in commit 4580a92 (NFS: Use
> > server-recommended security flavor by default (NFSv3)).
> 
> As an aside, this (from the patch description for 4580a92):
> 
> >     If a server lists Kerberos pseudoflavors before "sys" in its export
> >     options, our client now chooses Kerberos over AUTH_UNIX for mount
> >     points, when no security flavor is specified by the mount command.
> >     This could be surprising to some administrators or users, who would
> >     then need to have Kerberos credentials to access the export.
> 
> 
> is a description of side-effects of the changes in 4580a92.  This text is intended as a warning that behavior could change after 4580a92, not as a statement of purpose.  It describes a known limitation of the approach introduced in 4580a92.
> 
> > While the workarounds are fine, I think we can do better here and allow
> > this to keep "just working". Allow the client to fall back to
> > automatically trying AUTH_UNIX under if the following are all true:
> > 
> >    - the server return -EACCES from ->create_server call
> >    - the client had to do a MNT request (i.e. no binary options)
> >    - we didn't just try to use AUTH_UNIX
> >    - the admin did not explcitly specify a sec= option
> > 
> > At that point, try to use AUTH_UNIX, if the server listed it.
> 
> During these checks, how do you know the server specified AUTH_SYS in its list?  It seems to me you want to retry with the next flavor in server_authlist until you've exhausted the list.
> 

Oh and to answer your question, we don't know that at this point, but
it won't matter.

This patch sets args->auth_flavors[0] = RPC_AUTH_UNIX and then has it
call nfs_select_flavor() again. If the server didn't have AUTH_UNIX in
its list, then that function will fail at that point and we can just
return the error.

-- 
Jeff Layton <jlayton@redhat.com>
