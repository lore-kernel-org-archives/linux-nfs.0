Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aa.linuxbox.com ([69.128.83.226]:4001 "EHLO aa.linuxbox.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755261Ab3JXP3g (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Oct 2013 11:29:36 -0400
Date: Thu, 24 Oct 2013 11:29:25 -0400 (EDT)
From: "Matt W. Benjamin" <matt@linuxbox.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Christoph Anton Mitterer <calestyo@scientia.net>,
        linux-nfs <linux-nfs@vger.kernel.org>, Simo Sorce <simo@redhat.com>
Message-ID: <2102567502.56.1382628565761.JavaMail.root@thunderbeast.private.linuxbox.com>
In-Reply-To: <20131024112319.7ad9fd27@tlielax.poochiereds.net>
Subject: Re: XATTRs in NFS?
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

It appears that there could be spec implications, but I have not so far been convinced that
nfsv4.x named attributes are not an appropriate vehicle for (some set of) extended attributes.

The fact that nfsv4.x named attributes are suitable to represent large objects, does not make
them unsuitable to represent key value properties.

Matt

----- "Jeff Layton" <jlayton@redhat.com> wrote:

> On Thu, 24 Oct 2013 11:16:10 -0400
> Simo Sorce <simo@redhat.com> wrote:
> 
> > On Thu, 2013-10-24 at 15:11 +0000, Myklebust, Trond wrote:
> > > On Thu, 2013-10-24 at 11:07 -0400, Simo Sorce wrote:
> > > 
> > > > Because the filesystem can do that when multiple applications
> are
> > > > involved without having to change them all to talk to each other
> and
> > > > invent custom protocol all the time just to keep some
> additional
> > > > metadata associated to a file..
> > > > 
> > > It's still a custom protocol. The applications need to agree on a
> data
> > > format and store it somewhere. The portable way to do this is to
> write
> > > an application library that they can link to.
> > 
> > Perhaps I was unclear, you are never going to see that custom
> library
> > linked into the 'mv' command.
> > 
> > So your approach makes little sense if the object is to maintain
> data
> > coherent when people need to handle files from random applications
> and
> > scripts and general system maintenance.
> > 
> > The data may be relevant only to a specific application.
> > 
> > I am not saying you *have* to implement xattrs support, just saying
> that
> > it is not a mere 'applications should synchronize data themselves'
> > problem.
> > 
> 
> I think the real solution if people need this is to lead an effort to
> put xattrs into the spec. I think there is still time to get new
> features into v4.3 if someone wants to champion it...
> 
> -- 
> Jeff Layton <jlayton@redhat.com>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Matt Benjamin
The Linux Box
206 South Fifth Ave. Suite 150
Ann Arbor, MI  48104

http://linuxbox.com

tel.  734-761-4689 
fax.  734-769-8938 
cel.  734-216-5309 
