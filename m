Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:45939 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759188Ab3EGVYG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 May 2013 17:24:06 -0400
Date: Tue, 7 May 2013 17:00:20 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: long delay when mounting due to SETCLIENTID AUTH_GSS attempts
Message-ID: <20130507170020.15efeedc@tlielax.poochiereds.net>
In-Reply-To: <20130507205321.GE32743@fieldses.org>
References: <20130503132557.2fdf794d@tlielax.poochiereds.net>
	<AE700845-4032-4BEC-817C-97EB08A831E8@oracle.com>
	<20130503142421.19fb3ca6@tlielax.poochiereds.net>
	<1367606034.3556.25.camel@leira.trondhjem.org>
	<20130503144437.3a47e476@tlielax.poochiereds.net>
	<A2E5B3F1-A8F1-4731-A66C-548B9C8FD429@oracle.com>
	<20130503211810.GF5715@fieldses.org>
	<8F91C5FB-EE7F-48F8-9ED5-6B5D8503E248@oracle.com>
	<20130507205321.GE32743@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 7 May 2013 16:53:21 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Fri, May 03, 2013 at 05:50:49PM -0400, Chuck Lever wrote:
> > 
> > On May 3, 2013, at 5:18 PM, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > 
> > > On Fri, May 03, 2013 at 02:48:59PM -0400, Chuck Lever wrote:
> > >> We should always use krb5i if a GSS context can be established with
> > >> our machine cred.  As I said before, SETCLIENTID and
> > >> GETATTR(fs_locations) really should use an integrity-protecting
> > >> security flavor no matter what flavor is in effect on the mount points
> > >> themselves.
> > > 
> > > Can you give an example of a threat that could be avoided by this?
> > > 
> > > My suspicion is that in most cases an attacker with the ability to
> > > subvert auth_sys could *also* DOS gssd, and hence force the fallback to
> > > auth_sys.
> > > 
> > > krb5i plus a fallback to auth_sys on failure to authenticate doesn't
> > > sound to me much more secure than just auth_sys.
> > 
> > Our current situation is that the first mount of a server determines the flavor to use for SETCLIENTID.  So if that mount happens to be "sec=sys" the SETCLIENTID is done with AUTH_SYS no matter what the subsequent mounts request.
> > 
> > That's just about as secure in many cases as falling back.
> > 
> > > If we really want much security benefit from krb5i on state operations,
> > > I think we need to really *require* krb5i.
> > > 
> > > So I'm inclined towards Jeff's solution: don't do this unless userspace
> > > somehow affirmatively states that it requires krb5i on state operations.
> > 
> > This would have to be on a per-server basis.  Where would an admin specify such an option?  I don't believe either a mount option (too fine) or a module parameter (too coarse) is appropriate.
> 
> Why do you think a mount option is too fine?  They can use nfsmount.conf
> to specify per-server or global defaults.
> 
> > > I agree that we should default to this when we can.  But the way to move
> > > towards that default is then to get distributions to turn on the new
> > > module parm (or whatever it is) by default.  As they do so, they can
> > > also ensure that e.g. gssd is started.
> > 
> > gssd is not all that's required.
> 
> Isn't that's all that's required to fix the delay problem?  Or do you
> still get a delay if you run gssd but don't create a keytab?
> 

It seems like running gssd is sufficient to make the delay go away
for me. The upcall gets a quick negative response and then the kernel
falls back to doing AUTH_SYS.

While that's a reasonable workaround for now, I'm not sure we want a
solution that requires having yet another daemon running if we can get
away with it.

-- 
Jeff Layton <jlayton@redhat.com>
