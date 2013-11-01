Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:17844 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752627Ab3KAQ5X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Nov 2013 12:57:23 -0400
Date: Fri, 1 Nov 2013 12:57:19 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "cye@redhat.com" <cye@redhat.com>,
        "dpquigl@davequigley.com" <dpquigl@davequigley.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs: fix oops when trying to set SELinux label
Message-ID: <20131101125719.38843cfb@tlielax.poochiereds.net>
In-Reply-To: <1383324599.2911.2.camel@leira.trondhjem.org>
References: <1383317372-3373-1-git-send-email-jlayton@redhat.com>
	<20131101120211.586aef7a@corrin.poochiereds.net>
	<1383324599.2911.2.camel@leira.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 1 Nov 2013 16:50:00 +0000
"Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Fri, 2013-11-01 at 12:02 -0400, Jeff Layton wrote:
> > It looks like _nfs4_get_security_label() has the same problem, but I've
> > so far been unable to get it to be called, so I didn't patch it. It
> > seems like getxattr does some special stuff for SELinux labels that
> > cause them only to ever be fetched once.
> > 
> > Is there some trick to it?
> > 
> 
> Doesn't 'ls -Z' cause them to security label to be read again?
> 

As best I can tell, security labels are set on the inode when the inode
is instantiated, and then are reset on changes (i.e. setxattr). If
another client changes the label though, it's not clear to me how your
client would ever notice it until the inode is dropped from the cache.

ISTR Eric Paris explaining to me that they do that for performance
reasons but it seems like something that needs to be reconsidered in
light of labeled NFS. Not picking up a security label change seems like
a bug, IMO...

> Either way, the fix is clearly needed, so I've added the patch, and Cced
> stable.
> 

Thanks!
-- 
Jeff Layton <jlayton@redhat.com>
