Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41362 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753269Ab3ECVSO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 May 2013 17:18:14 -0400
Date: Fri, 3 May 2013 17:18:10 -0400
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Jeff Layton <jlayton@redhat.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: long delay when mounting due to SETCLIENTID AUTH_GSS attempts
Message-ID: <20130503211810.GF5715@fieldses.org>
References: <20130503132557.2fdf794d@tlielax.poochiereds.net>
 <AE700845-4032-4BEC-817C-97EB08A831E8@oracle.com>
 <20130503142421.19fb3ca6@tlielax.poochiereds.net>
 <1367606034.3556.25.camel@leira.trondhjem.org>
 <20130503144437.3a47e476@tlielax.poochiereds.net>
 <A2E5B3F1-A8F1-4731-A66C-548B9C8FD429@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <A2E5B3F1-A8F1-4731-A66C-548B9C8FD429@oracle.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 03, 2013 at 02:48:59PM -0400, Chuck Lever wrote:
> We should always use krb5i if a GSS context can be established with
> our machine cred.  As I said before, SETCLIENTID and
> GETATTR(fs_locations) really should use an integrity-protecting
> security flavor no matter what flavor is in effect on the mount points
> themselves.

Can you give an example of a threat that could be avoided by this?

My suspicion is that in most cases an attacker with the ability to
subvert auth_sys could *also* DOS gssd, and hence force the fallback to
auth_sys.

krb5i plus a fallback to auth_sys on failure to authenticate doesn't
sound to me much more secure than just auth_sys.

If we really want much security benefit from krb5i on state operations,
I think we need to really *require* krb5i.

So I'm inclined towards Jeff's solution: don't do this unless userspace
somehow affirmatively states that it requires krb5i on state operations.

I agree that we should default to this when we can.  But the way to move
towards that default is then to get distributions to turn on the new
module parm (or whatever it is) by default.  As they do so, they can
also ensure that e.g. gssd is started.

--b.

> > Instead of using AUTH_GSS for SETCLIENTID by default, would it make
> > sense to add a switch (module parm?) that turns it on so that it can be
> > an opt-in thing rather than doing this by default?
> 
> Why add another tunable when we really should just fix the delay?
> 
> Besides, if gssd is running and no keytab exists, then the fallback to AUTH_SYS should be fast. Is that not an effective workaround until we address the delay problem?
> 
> -- 
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> 
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
