Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aa.linuxbox.com ([134.215.213.37]:3230 "EHLO aa.linuxbox.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758958Ab2C3RLT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Mar 2012 13:11:19 -0400
Date: Fri, 30 Mar 2012 13:10:57 -0400 (EDT)
From: "Matt W. Benjamin" <matt@linuxbox.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Boaz Harrosh <bharrosh@panasas.com>, linux-nfs <linux-nfs@vger.kernel.org>,
        Ganesha NFS List <nfs-ganesha-devel@lists.sourceforge.net>,
        Peter Staubach <pstaubach@exagrid.com>
Message-ID: <2010727361.65.1333127457578.JavaMail.root@thunderbeast.private.linuxbox.com>
In-Reply-To: <1333122400.8099.17.camel@lade.trondhjem.org>
Subject: Re: unlink within an open directory stream
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

Thanks for providing all this reasoning and additional background.

I guess I've always constructed an imaginary intention of the protocol feature that's different from the actual one.  Yet the feature nevertheless seemed useful.

There seem to be two parts to my construction:

1. negatively, it never occurred to me that a client implementation would assume that it could protect an application from invalidation, unless it was able to perform, and cache a complete traversal--this would be one with a consistent verifier for all component readdirs

2. at the same time, it seems a conforming server implementation can be made which would often support a client in doing this, presuming it was able to use the cookie verifier to select a prior version of the directory;  not only do some filesystems now appear able to do this, this technique is used by the dcache nfs server, though iiuc, dcache doesn't make any promises that it will have a specific component cached at every version, etc

Matt

----- "Trond Myklebust" <Trond.Myklebust@netapp.com> wrote:

> On Fri, 2012-03-30 at 11:24 -0400, Peter Staubach wrote:
> > Yes, hmmm, ummm...
> > 
> > A long time, I thought that the readdir cookie verifier sounded like
> a good idea.  After all, if directories can be compacted, it would be
> nice to be able to tell when the cookie has become invalid, right? 
> So, I added it to the NFSv3 protocol.
> > 
> > It was only afterwards, in attempting to implement it, that the real
> truth was discovered.  This is that the interfaces are not sufficient
> to be able to convey this information sufficiently and to be able to
> recover from the situation.  Currently, recovery require action on the
> part of the application.
> > 
> > In retrospect, I wouldn't add the cookie verifier if I was doing it
> again.
> > 
> > Thanks for the support, though.  :-)
> > 
> > I do disagree with Trond though, in that applications must be coded
> to be able to handle directories where cookies can become invalidated.
>  That's why rm and such have to be coded to keep track of their
> location in the directory by more than just d_off.
> 
> The problem with that is that there is no standard for how
> applications
> should proceed to do this, and so there are no guidelines for how the
> client should behave.
> 
> Worse, if you've looked at the glibc readdir library code, you'll
> have
> noticed that it _depends_ on being able to use a strictly
> POSIX-conforming version of telldir()/seekdir(). If it can't rewind to
> a
> previously saved offset, then it can end up skipping entries.
> 
> So no, I can't rely on applications either...
> 
> > 		ps
> > 
> > 
> > -----Original Message-----
> > From: linux-nfs-owner@vger.kernel.org
> [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Matt W.
> Benjamin
> > Sent: Monday, March 26, 2012 2:55 PM
> > To: Boaz Harrosh
> > Cc: linux-nfs; Ganesha NFS List; Trond Myklebust
> > Subject: Re: unlink within an open directory stream
> > 
> > Hi,
> > 
> > Boaz:  we do not any longer send a readdir index.  We do send a
> cookieverf.
> > 
> > Fist of all, I haven't established that the issue we're actually
> observing is caused by the Linux client sending old cookies to
> readdir(something).  However, if it is, it's in no way better to try
> to make cookies "more persistent."  Nor should the Linux client be
> expecting it.  The assumption is simply flawed.  The protocol
> introduced cookie verifier (a LONG time ago) for a reason.
> > 
> > Matt
> > ----- "Boaz Harrosh" <bharrosh@panasas.com> wrote:
> > 
> > > On 03/26/2012 11:25 AM, Myklebust, Trond wrote:
> > > 
> > > > On Mon, 2012-03-26 at 11:17 -0700, Boaz Harrosh wrote:
> > > >> On 03/24/2012 10:12 AM, Myklebust, Trond wrote:
> > > >>
> > > >>
> > > >> It's the new (post RHEL 6.0 Kernel) NFS need for opendir after
> an
> > > unlink.
> > > > 
> > > > What?
> > > > 
> > > 
> > > 
> > > The links below report on regression in RHEL 6.2 which have a new
> NFS 
> > > implementation where  6.0 used to be fine.
> > > (Or it's what I understood from the reporters)
> > > 
> > > <snip>
> > > 
> > > > 
> > > 
> > > > No.
> > > > 
> > > > If the server supports permanent readdir cookies, then there is
> no
> > > need
> > > > for opendir after unlink.
> > > > 
> > > > If the server does not have permanent readdir cookies, then our
> > > client
> > > > has never supported it anyway (nor will it ever do so). That
> whole 
> > > > 'cookieverf' READDIR bullshit has never provided a workable
> model
> > > for a
> > > > POSIX client...
> > > 
> > > 
> > > Thanks Trond for the explanation. Forgive my slowness. So you are
> 
> > > saying that with knfsd it's actually filesystem dependent and
> maybe 
> > > the reporters did not compare apples-to-apples and the difference
> is 
> > > in the behind file system.
> > > 
> > > Matt I'm sure Trond is right with regard to Ganesha, because we
> send a 
> > > readdir index and a cookieverf, which will change after unlink.
> Since 
> > > the application does not call opendir again the client will send
> the 
> > > old cookies, which is now a different file or might get
> out-of-bounds 
> > > for Ganesha.
> > > 
> > > Let me think about it a bit. I'm sure we can send a Better 64bit 
> > > cookie, which will be more persistent, even across unlinks.
> > > 
> > > > 
> > > > 
> > > 
> > > 
> > > Thanks
> > > Boaz
> > 
> > --
> > Matt Benjamin
> > The Linux Box
> > 206 South Fifth Ave. Suite 150
> > Ann Arbor, MI  48104
> > 
> > http://linuxbox.com
> > 
> > tel. 734-761-4689
> > fax. 734-769-8938
> > cel. 734-216-5309
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs"
> in the body of a message to majordomo@vger.kernel.org More majordomo
> info at  http://vger.kernel.org/majordomo-info.html
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com

-- 
Matt Benjamin
The Linux Box
206 South Fifth Ave. Suite 150
Ann Arbor, MI  48104

http://linuxbox.com

tel. 734-761-4689
fax. 734-769-8938
cel. 734-216-5309
