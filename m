Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:29349 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761616Ab3DDPsE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Apr 2013 11:48:04 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "tigran.mkrtchyan@desy.de" <tigran.mkrtchyan@desy.de>
CC: Jim Rees <rees@umich.edu>, linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: readdir vs. getattr
Date: Thu, 4 Apr 2013 15:48:01 +0000
Message-ID: <1365090480.10726.22.camel@leira.trondhjem.org>
References: <CAGue13pe_ZH_Eto-jL3mLjTNGFK26izTarnZdjs3eL82A2Z37w@mail.gmail.com>
	 <20130404151507.GA8484@umich.edu>
	 <CAGue13o6X5S3ppTX_fmMCTCX=7Mq_57YQEsb_hkOKwN9iOHwEQ@mail.gmail.com>
In-Reply-To: <CAGue13o6X5S3ppTX_fmMCTCX=7Mq_57YQEsb_hkOKwN9iOHwEQ@mail.gmail.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-04-04 at 17:38 +0200, Tigran Mkrtchyan wrote:
> On Thu, Apr 4, 2013 at 5:15 PM, Jim Rees <rees@umich.edu> wrote:
> > Tigran Mkrtchyan wrote:
> >
> >   we have a directory with 50K (number of )  files in it.
> >   The user does a 'ls' and I can see READDIR4. To
> >   get the complete listing a client need to send ~380 requests.
> >   Now user does yet another 'ls' in the same directory.
> >   The client sends a GETATTR  on directorie's FH
> >   (actually two of GETATTRS - why?!!) and discovers that a
> >   directory didn't change and re-uses existing listing, BUT!!!
> >   for each file in the directory it sends a GETATTR to discover
> >   is  the file's attributes are changed. For 50K files it's a 50K requests.
> >
> > So is this a "ls -l"? Because for "ls" it shouldn't stat all the files.
> 
> I believe it's 'ls -l'.  Well, you probably want to say that it's ls
> calling stat on each file. Nevertheless client still should re-use
> cached information.

What makes you think that it isn't using cached information? I'm
guessing you just need to adjust the values of acregmin and acregmax
upwards.

That said, we might be able to be a little more intelligent about how we
use the NFS_INO_ADVISE_RDPLUS hint, and have it blow out the readdir
cache when we find ourselves doing lots of lookup revalidates.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
