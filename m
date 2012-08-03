Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:23060 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752746Ab2HCKwd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 Aug 2012 06:52:33 -0400
Date: Fri, 3 Aug 2012 06:52:31 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Andrei Warkentin <awarkentin@vmware.com>
Cc: linux-nfs@vger.kernel.org, Ed Goggin <egoggin@vmware.com>
Subject: Re: stale or not stale
Message-ID: <20120803065231.2e64ec8d@corrin.poochiereds.net>
In-Reply-To: <1592211005.4733808.1343960954717.JavaMail.root@vmware.com>
References: <1781697815.4540720.1343959078882.JavaMail.root@vmware.com>
	<1592211005.4733808.1343960954717.JavaMail.root@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2 Aug 2012 19:29:14 -0700 (PDT)
Andrei Warkentin <awarkentin@vmware.com> wrote:

> ----- Original Message -----
> > From: "Ed Goggin" <egoggin@vmware.com>
> > To: linux-nfs@vger.kernel.org
> > Sent: Thursday, August 2, 2012 9:57:58 PM
> > Subject: stale or not stale
> > 
> > 
> > It seems that nfsd can return reply attributes with a link count of
> > zero but without an NFS3ERR_STALE status.  We've seen this actually
> > happen for a write request to a file with a single link that  is
> > concurrently being removed without NLM lock protection.  What is the
> > proper behavior here?
> 
> I think it would be worthwhile to add here that the the remove was not concurrent with the write, and at the time of the NFS write a new file with the same name existed, yet fh decoding picked up the old inode instead of reporting -ESTALE. FS was ext4.
> 
> In fact seen two things happen - n_link = 0 and n_link = 1, and in both cases we knew the file was unlink()ed and re-creat()ed.
> 

That's entirely valid behavior.

ESTALE from the server is its way of saying: "I don't recognize that
filehandle". It can't figure out how to match that filehandle to an
inode.

An i_nlink count of 0 means that there are no more hardlinks attached
to the inode. It's deleted from the namespace, but the inode still
exists until there are no more i_count references held on it.

-- 
Jeff Layton <jlayton@redhat.com>
