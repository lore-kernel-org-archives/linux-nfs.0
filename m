From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [NFS] NFS/krb and batch jobs - doable?
Date: Fri, 9 Oct 2009 12:16:02 -0400
Message-ID: <20091009121602.5ec86dfb@tlielax.poochiereds.net>
References: <c8e974302190b867ad8ea49d8158f1db.squirrel@webmail.rainiday.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: raini-9HxftnAiGddWk0Htik3J/w@public.gmane.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32601 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758831AbZJIQQb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Oct 2009 12:16:31 -0400
In-Reply-To: <c8e974302190b867ad8ea49d8158f1db.squirrel-2RFepEojUI30fF+2cCIZ11aTQe2KTcn/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 9 Oct 2009 08:15:12 -0700
raini-9HxftnAiGddWk0Htik3J/w@public.gmane.org wrote:

> I've been struggling for some time to understand how to allow users of
> long-running batch jobs to continue to do so in an environmnet migrated to
> NFS4 with kerberos (from non-kerberized NFS), centered around the problem
> of keeping their batch job credentials separate from login credentials,
> which might otherwise mangle or delete them and cause the batch jobs to
> die on logout - or say if the users opted for renewable tickets for the
> job explicitly but the system default is non-renewable.
> 
> The central problem seems to be that NFS4 (on Linux at least) doesn't
> support the concept of multiple sessions, and seems to expect to see a
> standard ccache filename /tmp/krb5cc_${UID}.  Am I right in thinking this
> is a fundamental limitation? 

No, gssd (the client side daemon) will search /tmp for anything that
looks like a credcache for the right user, verify that it is a
credcache and then pick the one with the latest TGT expiration.

>  I've played with KRB5CCNAME but am led to
> believe NFS ignores this; I've also added ccname template settings to
> krb5.conf and PAM to try to fool NFS into separating batch job credentials
> from user ones, but don't seem to be getting a robust separation.
> 

You're correct that NFS ignores $KRB5CCNAME. It uses the above (less
than optimal) heuristic instead.

> The essential problem is that I need an environment where a user can
> obtain credentials that may be different from the desirable interactive
> default (e.g. longer duration, renewable), then run a batch job, ideally
> in the heterogeneous ways they do currently - run via a shell, kicked off
> on another machine via ssh, via condor - and not have its credentials at
> risk if the user then logs into the machine it's running on, submits a
> second job etc.
> 
> Is this doable currently?  I'm surprised (so far) to not run across people
> who are doing this, and would be very surprised if it's not a requirement
> for many.  If not, is it likely to be doable soon and what does it depend
> on?
> 

Probably doable, but not trivial. IIRC, the kernel tracks credentials
by uid. You'd need to determine some way to split that up so that each
"session" has separate credentials. Once you do that, you'll have to
have the kernel pass enough info to the upcall for it to determine what
credcache it should use and modify gssd to use the new info accordingly.

-- 
Jeff Layton <jlayton@redhat.com>
