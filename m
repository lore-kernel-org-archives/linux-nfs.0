Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-o-3.desy.de ([131.169.56.156]:57032 "EHLO smtp-o-3.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751642AbaA2JVp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Jan 2014 04:21:45 -0500
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
	by smtp-o-3.desy.de (DESY-O-3) with ESMTP id ACD94280961
	for <linux-nfs@vger.kernel.org>; Wed, 29 Jan 2014 10:21:43 +0100 (CET)
Received: from ZITSWEEP1.win.desy.de (zitsweep1.win.desy.de [131.169.97.95])
	by smtp-map-3.desy.de (DESY_MAP_3) with ESMTP id 969BE10F5
	for <linux-nfs@vger.kernel.org>; Wed, 29 Jan 2014 10:21:43 +0100 (MET)
Date: Wed, 29 Jan 2014 10:21:43 +0100 (CET)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: NeilBrown <neilb@suse.de>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Jim Rees <rees@umich.edu>, linux-nfs <linux-nfs@vger.kernel.org>
Message-ID: <1342984553.746756.1390987303295.JavaMail.zimbra@desy.de>
In-Reply-To: <20140129182532.7479eeda@notabene.brown>
References: <CAGue13pe_ZH_Eto-jL3mLjTNGFK26izTarnZdjs3eL82A2Z37w@mail.gmail.com> <20130404151507.GA8484@umich.edu> <CAGue13o6X5S3ppTX_fmMCTCX=7Mq_57YQEsb_hkOKwN9iOHwEQ@mail.gmail.com> <1365090480.10726.22.camel@leira.trondhjem.org> <20140129182532.7479eeda@notabene.brown>
Subject: Re: readdir vs. getattr
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

(without knowing kernel details)

What about some stat counter and trigger readdirplus instead of next getattr if
some threshold are reached. Let say directory has more than 8000 entries and 
getattr was called on 10% of the files. Of course you have to watch this per
process.

Tigran.

----- Original Message -----
> From: "NeilBrown" <neilb@suse.de>
> To: "Trond Myklebust" <trond.myklebust@primarydata.com>
> Cc: "tigran mkrtchyan" <tigran.mkrtchyan@desy.de>, "Jim Rees" <rees@umich.edu>, "linux-nfs"
> <linux-nfs@vger.kernel.org>
> Sent: Wednesday, January 29, 2014 8:25:32 AM
> Subject: Re: readdir vs. getattr
> 
> 
> (resent with correct address for Trond)
> 
> On Thu, 4 Apr 2013 15:48:01 +0000 "Myklebust, Trond"
> <Trond.Myklebust@netapp.com> wrote:
> 
> > On Thu, 2013-04-04 at 17:38 +0200, Tigran Mkrtchyan wrote:
> > > On Thu, Apr 4, 2013 at 5:15 PM, Jim Rees <rees@umich.edu> wrote:
> > > > Tigran Mkrtchyan wrote:
> > > >
> > > >   we have a directory with 50K (number of )  files in it.
> > > >   The user does a 'ls' and I can see READDIR4. To
> > > >   get the complete listing a client need to send ~380 requests.
> > > >   Now user does yet another 'ls' in the same directory.
> > > >   The client sends a GETATTR  on directorie's FH
> > > >   (actually two of GETATTRS - why?!!) and discovers that a
> > > >   directory didn't change and re-uses existing listing, BUT!!!
> > > >   for each file in the directory it sends a GETATTR to discover
> > > >   is  the file's attributes are changed. For 50K files it's a 50K
> > > >   requests.
> > > >
> > > > So is this a "ls -l"? Because for "ls" it shouldn't stat all the files.
> > > 
> > > I believe it's 'ls -l'.  Well, you probably want to say that it's ls
> > > calling stat on each file. Nevertheless client still should re-use
> > > cached information.
> > 
> > What makes you think that it isn't using cached information? I'm
> > guessing you just need to adjust the values of acregmin and acregmax
> > upwards.
> > 
> > That said, we might be able to be a little more intelligent about how we
> > use the NFS_INO_ADVISE_RDPLUS hint, and have it blow out the readdir
> > cache when we find ourselves doing lots of lookup revalidates.
> > 
> 
> Pop.
> 
> I recently had a customer raise exactly this issue with me, so I've been
> looking into it.
> 
> I don't think it can really be fixed by adjusting acregmin/acregmax.
> 
> Once you have done READDIRPLUS, you have the directory contents in the
> page-cache and will continue to use those contents until they drop out of the
> cache, or until the directory changes in some way.
> 
> Meanwhile the stat information from the READDIRPLUS was used to create/update
> info in the inode table and that will eventually become stale.  As soon as it
> becomes stale you get a GETATTR storm on the next "ls -l" instead of a few
> READDIRPLUS calls.  By increasing acregmin you can delay that storm, but you
> can put it off forever.
> 
> Fixing this is tricky.  We really want to know on the first nfs_readdir()
> call
> whether it will be followed by lookups or not.  If it won't, then using the
> cached data is fine.  If it will, then we really want a READDIRPLUS.
> 
> The only way I can see to address this is for nfs_advise_use_readdirplus  (or
> code near where that is called) to notice that a readdir is currently active
> on the same directory and is using cached data, and to re-use that 'open' of
> the directory to do a readdirplus.  This would update the stat info for the
> current inode and all the other inodes for the directory.
> 
> This is fairly horrible.  The 'struct file' used by the readdir would need to
> be stored somewhere so that nfs_lookup_revalidate can use it (if process
> permissions allow).  If multiple processes were doing a readdir at the same
> time .... I would certainly get confused.
> 
> However I cannot think of anything else that would even come close to being a
> real solution.
> 
> Any solution that just modified nfs_readdir() could only avoid the GETATTR
> storm by largely ignoring the cached information and (almost) always calling
> READDIRPLUS.
> 
> Does anyone have any other ideas?  Or do you think it is worth trying to
> implement the above "horrible" idea.  I did start working on it, but only got
> far enough to understand the full extend of what is required.
> 
> Thanks,
> NeilBrown
> 
