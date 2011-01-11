Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mexforward.lss.emc.com ([128.222.32.20]:19640 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754734Ab1AKArI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Jan 2011 19:47:08 -0500
From: <Daniel.Muntz@emc.com>
To: <shtylman@athenacr.com>, <jlayton@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Date: Mon, 10 Jan 2011 19:38:43 -0500
Subject: RE: question about nfs4 with krb5 behavior
Message-ID: <DE966DA98A4ABE438D726BDF1699CF61043985AADB@MX05A.corp.emc.com>
In-Reply-To: <201101101545.21890.shtylman@athenacr.com>
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Best practice for AFS is to only allow one user at a time, especially if users can become root.  You'd also want to delete any "persistent" cache when users change and have a mechanism of validating/replacing kernel and apps.

  -Dan

-----Original Message-----
From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Roman Shtylman
Sent: Monday, January 10, 2011 12:45 PM
To: Jeff Layton
Cc: linux-nfs@vger.kernel.org
Subject: Re: question about nfs4 with krb5 behavior


On Monday, January 10, 2011 03:35:04 pm Jeff Layton wrote:
> On Mon, 10 Jan 2011 14:55:30 -0500
> 
> Roman Shtylman <shtylman@athenacr.com> wrote:
> > I have setup nfs4 with krb5 server and successfully mounted a client. Two
> > people can log into the client box and both access their respective
> > shares and not each other's. However, when one user (who lets say has
> > root privs) uses root to become the second user (using su) then that
> > user can now access the info of the user he became.
> > 
> > I was under the impression that this should not be possible as the
> > tickets for access should still be tied to the first user they logged in
> > as. Is this true? Or do I have an error in my setup?
> > 
> > Process:
> > Login as user A
> > (User B logs into the machine from another terminal)
> > sudo su B (to become user B on the machine)
> > <can now edit files which belong to B>
> 
> That's correct, or is at least in accordance with the design. The
> credcache is (usually) a file in /tmp. The kernel has to upcall to
> userspace for that information. To do that, it passes along the uid of
> the owner of the credcache. I think this is governed by the fsuid.
> 
> When you "su" to another user, all of the uid's associated with the
> process are changed (real, effective, fs and saved). So, the uid passed to
> the upcall in this case is B's and not A's.
> 
> This could potentially be "fixable" by moving the krb5 credcache into
> the per-session keyring and then teach nfs to do keys API upcalls to get
> the right blob. Not a trivial project, but it's doable. This is
> something that would be nice for CIFS and maybe AFS too.

AFS does not have this behavior. 

What is a best practice for handling this situation? Prevent "untrusted" 
machines from connecting to the nfs server? Basically any machine where a 
normal user can become root would be a potential problem?

Thanks for the quick response.

cheers,
~Roman

> 
> > If User B does not login before user A becomes user B, user A is not able
> > to edit user B's files even after he becomes user B.
> 
> I suspect that that's just a negative cache entry that will eventually
> time out.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

