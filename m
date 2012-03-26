Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aa.linuxbox.com ([134.215.213.37]:1825 "EHLO aa.linuxbox.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753404Ab2CZT3u (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Mar 2012 15:29:50 -0400
Date: Mon, 26 Mar 2012 15:29:15 -0400 (EDT)
From: "Matt W. Benjamin" <matt@linuxbox.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Boaz Harrosh <bharrosh@panasas.com>, linux-nfs <linux-nfs@vger.kernel.org>,
        Ganesha NFS List <nfs-ganesha-devel@lists.sourceforge.net>
Message-ID: <923219433.84.1332790155474.JavaMail.root@thunderbeast.private.linuxbox.com>
In-Reply-To: <1598378492.82.1332790088063.JavaMail.root@thunderbeast.private.linuxbox.com>
Subject: Re: unlink within an open directory stream
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

----- "Trond Myklebust" <Trond.Myklebust@netapp.com> wrote:

> On Mon, 2012-03-26 at 14:55 -0400, Matt W. Benjamin wrote:
> > Hi,
> > 
> > Boaz:  we do not any longer send a readdir index.  We do send a
> cookieverf.
> 
> Uhh... That would be so broken, that I can't imagine that is true...

I think you're misreading my statement.  My intended meaning had to do with Ganesha's generator
for the cookies themselves.  It's not relevant.

> 
> > Fist of all, I haven't established that the issue we're actually
> observing is caused
> > by the Linux client sending old cookies to readdir(something). 
> However, if it is,
> > it's in no way better to try to make cookies "more persistent."  Nor
> should the Linux
> > client be expecting it.  The assumption is simply flawed.  The
> protocol introduced
> > cookie verifier (a LONG time ago) for a reason.
> 
> Bullshit... The cookie verifier is unimplementable. Feel free to try
> or
> to show me an implementation that works. However I refuse to waste
> any
> more of my time trying to make that crap work, having already wasted
> several months of my life doing just that.

There must be something I'm missing here, but ok.

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
