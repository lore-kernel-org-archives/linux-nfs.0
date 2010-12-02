Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46592 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757274Ab0LBWaI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Dec 2010 17:30:08 -0500
Date: Thu, 2 Dec 2010 17:30:04 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Trond Myklebust <trond.myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: Umask and ACL on NFS
Message-ID: <20101202223004.GH8583@fieldses.org>
References: <m3tyiw4ejo.fsf@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <m3tyiw4ejo.fsf@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Dec 02, 2010 at 04:39:15PM +0530, Aneesh Kumar K.V wrote:
> 
> Hi,
> 
> POSIX ACL and Richacl want to apply umask on file creation only when we don't have any
> inheritable ACEs on the parent directory. Currently with nfsv4 code we do
> check for POSIX ACL in nfs_atomic_lookup,

Huh.  Do you understand what that check is for?  I'm guessing it's just
a mistake, but I don't know....

> but i don't find where we set
> the MS_POSIXACL bit for the nfsv4 code.
> 
> Even if we try to do something like below
> 
>    if (nfs4_server_supports_acls(..))
>       sb->s_flags |= MS_POSIXACL;
> 
> I guess we could get it wrong. The above implies we may end up not
> applying umask for a server supporting ACL even if the parent 
> directory don't have inheritable ACEs.

Yeah, that doesn't look right.

> I found a proposal to add umask attribute at
> http://www.ietf.org/mail-archive/web/nfsv4/current/msg07159.html
> http://www.ietf.org/proceedings/74/slides/nfsv4-3.pdf
>                                 
> So what is the expected behaviour for NFS. Should we always apply
> umask (which is what it currently does) irrespective of whether
> parent directory have inheritable ACEs or not ?

I don't know.

So I guess the problems with aplying the umask are:

	- It's impossible then for inheritable ACEs to influence the
	  GROUP@ permission bits.  (Hm, I had some idea that 4.1
	  mode_set_masked helped here, but nope, can't see that it
	  does.)
	- If the umask group bit is nonzero then you likely end up with
	  inheritable ACEs for named users and groups being ineffective.

People hae indeed complained about this before; see e.g.

	http://marc.info/?t=123739823200003&r=1&w=2

for some previous discussion.  I think there are some others back there
someplace too.

--b.
