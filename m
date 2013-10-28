Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aa.linuxbox.com ([69.128.83.226]:4219 "EHLO aa.linuxbox.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753397Ab3J1VeT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Oct 2013 17:34:19 -0400
Date: Mon, 28 Oct 2013 17:34:00 -0400 (EDT)
From: "Matt W. Benjamin" <matt@linuxbox.com>
To: Ric Wheeler <rwheeler@redhat.com>
Cc: Mailing List Linux NFS <linux-nfs@vger.kernel.org>,
        Dr Fields James Bruce <bfields@fieldses.org>,
        Steve Dickson <SteveD@redhat.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Christoph Anton Mitterer <calestyo@scientia.net>
Message-ID: <63027038.131.1382996040648.JavaMail.root@thunderbeast.private.linuxbox.com>
In-Reply-To: <526EA65A.7010209@redhat.com>
Subject: Re: XATTRs in NFS?
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

We are prepared to contribute a draft implementation of -something-, and have planned
to do so.

We're currently working on Ganesha support.  I have assumed that what we
would implement is mapping of from user xattr to current nfsv4 named attributes.

Matt

----- "Ric Wheeler" <rwheeler@redhat.com> wrote:

> On 10/28/2013 01:49 PM, Myklebust, Trond wrote:
> > On Oct 28, 2013, at 12:15 PM, Christoph Anton Mitterer
> <calestyo@scientia.net> wrote:
> >
> >> On Mon, 2013-10-28 at 11:40 -0400, Ric Wheeler wrote:
> >>> Then you end up with large directories and an extra name per inode
> that needs to
> >>> be stored and extra lookups for each file when you do a whole file
> system crawl.
> >>>
> >>> Certainly not as easy as adding and xattrs with that information
> :)
> >> And I think there's another reason why it wouldn't work...
> >>
> >> Imagine I change my system to encode what should be XATTRs in
> hardlink
> >> pseudo files...
> >>
> >> If I have such pair locally e.g. on my ext4:
> >> /foo/bar/actual/file
> >> /meta/<SHA512 identifier>.2342348324
> >>
> >> And now move/copy the file via the network to the archive, I'd have
> to
> >> copy both files (which is really annoying), and I'd guess the
> inode
> >> coupling would get los (and at least the name wouldn't fit
> anymore).
> >>
> >> So the whole thing is IMHO not even a workaround.
> > OK. So you're going to do XATTRs for us?
> >
> > Trond
> 
> Now that pNFS is perfect and labeled NFS has made it upstream, I think
> that 
> Steve D must be looking for something to keep him busy :)
> 
> ric
> 
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
