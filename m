Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f53.google.com ([209.85.214.53]:36012 "EHLO
        mail-it0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751179AbdAXPRw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jan 2017 10:17:52 -0500
Received: by mail-it0-f53.google.com with SMTP id c7so87592590itd.1
        for <linux-nfs@vger.kernel.org>; Tue, 24 Jan 2017 07:17:51 -0800 (PST)
Date: Tue, 24 Jan 2017 09:17:45 -0600
From: Seth Forshee <seth.forshee@canonical.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Trond Myklebust <trondmy@primarydata.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] sunrpc: Use current_real_cred() when looking up rpc
 credentials
Message-ID: <20170124151745.GA114560@ubuntu-hedt>
References: <1481821992-77583-1-git-send-email-seth.forshee@canonical.com>
 <1481842899.11785.1.camel@primarydata.com>
 <20161216130609.GA124240@ubuntu-hedt>
 <20170110145504.GH52661@ubuntu-hedt>
 <87ziiyfntm.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <87ziiyfntm.fsf@xmission.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 11, 2017 at 01:21:57PM +1300, Eric W. Biederman wrote:
> Seth Forshee <seth.forshee@canonical.com> writes:
> 
> > On Fri, Dec 16, 2016 at 07:06:09AM -0600, Seth Forshee wrote:
> >> On Thu, Dec 15, 2016 at 11:01:41PM +0000, Trond Myklebust wrote:
> >> > On Thu, 2016-12-15 at 11:13 -0600, Seth Forshee wrote:
> >> > > Since 4.8 follow_automount() overrides the credentials with
> >> > > &init_cred before calling d_automount(). When
> >> > > rpcauth_lookupcred() is called in this context it is now using
> >> > > fs[ug]id from the override creds instead of from the user's
> >> > > creds, which can cause authentication to fail. To fix this, take
> >> > > the ids from current_real_cred() instead.
> >> > > 
> >> > > Cc: stable@vger.kernel.org # v4.8+
> >> > > CC: Eric W. Biederman <ebiederm@xmission.com>
> >> > > Fixes: aeaa4a79ff6a ("fs: Call d_automount with the filesystems
> >> > > creds")
> >> > > Signed-off-by: Seth Forshee <seth.forshee@canonical.com>
> >> > > ---
> >> > >  net/sunrpc/auth.c | 2 +-
> >> > >  1 file changed, 1 insertion(+), 1 deletion(-)
> >> > > 
> >> > > diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
> >> > > index 2bff63a73cf8..e6197b2bda86 100644
> >> > > --- a/net/sunrpc/auth.c
> >> > > +++ b/net/sunrpc/auth.c
> >> > > @@ -622,7 +622,7 @@ rpcauth_lookupcred(struct rpc_auth *auth, int
> >> > > flags)
> >> > >  {
> >> > >  	struct auth_cred acred;
> >> > >  	struct rpc_cred *ret;
> >> > > -	const struct cred *cred = current_cred();
> >> > > +	const struct cred *cred = current_real_cred();
> >> > >  
> >> > >  	dprintk("RPC:       looking up %s cred\n",
> >> > >  		auth->au_ops->au_name);
> >> > 
> >> > Among other things, this will break the access() syscall.
> >> 
> >> Okay, I see that now.
> >> 
> >> > It's completely the wrong level in which to override credentials.
> >> 
> >> The reason for it is that sget() now has a capability check which will
> >> fail on automount if current doesn't have CAP_SYS_ADMIN. So what are the
> >> alternatives? A few ideas:
> >> 
> >>  - Instead of using a completely differnet set of creds, we could copy
> >>    the current creds and raise CAP_SYS_ADMIN. This won't work if
> >>    curreent is in a different user ns however.
> >> 
> >>  - Filesystems could get around the capability check by using
> >>    sget_userns() during automount.
> >> 
> >>  - We could add a mount flag, say MS_AUTOMOUNT, and skip the capability
> >>    check if that is set.
> >> 
> >> Any opinions or other ideas?
> >
> > I haven't seen any responses, possibly just got lost in the shuffle
> > during the holidays (I know it slipped my mind for a while).
> >
> > Eric, what do you think about the last option above? From what I can see
> > looking up rpc credentials just isn't going to work with current_cred
> > overridden as we're doing for automount.
> 
> I got as far as there wasn't a correct thing to apply, and I have been
> bogged down in enough other things that I haven't gotten back to this
> one.
> 
> My gut feel is that we propbably want to do a little more reworking on
> the autmount path.  But I don't exactly have a concrete proposal for
> you at the moment.  I just found another 10 year old bug in the mount
> code...

With automounts we're mounting based on the credentials used when
mounting the parent. That's what your patch "fs: Call d_automount with
the filesystems creds" did, but it's overriding the credentials too
early in the call stack and causing these rpcauth problems.

But I think we should also be setting the submount's s_user_ns to be the
same as the parent's, not to current_user_ns. At that point we'd be
using the same credentials and user ns as when mounting the parent super
block, so we know the capability check would pass (since it passed for
the original mount) and don't really need to do it.

So if we could pass down through the call stack that a given mount
request is an automount from super block s (or at dentry d) then the fix
would be trivial. I don't see any way of passing that information
through currently though, without doing something undesirable like
adding arguments to the mount filesystem op.

Seth
