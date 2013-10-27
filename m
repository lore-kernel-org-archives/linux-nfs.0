Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aa.linuxbox.com ([69.128.83.226]:4341 "EHLO aa.linuxbox.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754695Ab3J0VW6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 27 Oct 2013 17:22:58 -0400
Date: Sun, 27 Oct 2013 17:22:42 -0400 (EDT)
From: "Matt W. Benjamin" <matt@linuxbox.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Dr Fields James Bruce <bfields@fieldses.org>,
        Christoph Anton Mitterer <calestyo@scientia.net>,
        Mailing List Linux NFS <linux-nfs@vger.kernel.org>,
        Wheeler Ric <ricwheeler@gmail.com>
Message-ID: <430357861.50.1382908962268.JavaMail.root@thunderbeast.private.linuxbox.com>
In-Reply-To: <5FC093E3-1CD3-4AC7-A91F-37C8DEC6BEFE@netapp.com>
Subject: Re: XATTRs in NFS?
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I was going for the point you make later in this thread:  "user xattrs are in
principle harmless."

The exposure policy for non-harmless xattrs issue is real enough, but my point was,
it seems to be a Linux policy issue, at the NFSv4 level just as it was at the syscall level.

The caching and atomicity issues seem like they actually are issues for NFSv4 discussion.
If the named attribute interface actually fails to cover xattrs, that's a big gaffe.

Matt


----- "Trond Myklebust" <Trond.Myklebust@netapp.com> wrote:

> On Oct 26, 2013, at 10:01 AM, Matt W. Benjamin <matt@linuxbox.com>
> wrote:
> 
> > Hi,
> > 
> > Surely you don't need NFSv4 to standardize the the (empty?) set of
> system or magic attributes Linux
> > should export?
> 
> The NFSv4 working group has no authority to do so. POSIX would be the
> right address.
> 
> > Besides, as you're well aware, most people who ask for xattrs are
> looking for an ability to associate
> > arbitrary specific data, not a back door ioctl interface.  That's
> clearly what the NFSv4 named attributes as standardized were intended
> for.
> 
> No. I'm not aware of that.
> 
> > I'm well aware of other uses and plans that someone would want to
> standardize, but it seems
> > irrelevant to the discussion.
> 
> It's very relevant to the discussion as it defines what namespace
> applications can expect to work.
> 
> Trond

-- 
Matt Benjamin
The Linux Box
206 South Fifth Ave. Suite 150
Ann Arbor, MI  48104

http://linuxbox.com

tel.  734-761-4689 
fax.  734-769-8938 
cel.  734-216-5309 
