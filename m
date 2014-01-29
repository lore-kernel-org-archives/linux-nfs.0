Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f176.google.com ([209.85.216.176]:50575 "EHLO
	mail-qc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751116AbaA2MSp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Jan 2014 07:18:45 -0500
Received: by mail-qc0-f176.google.com with SMTP id e16so2573202qcx.35
        for <linux-nfs@vger.kernel.org>; Wed, 29 Jan 2014 04:18:44 -0800 (PST)
Date: Wed, 29 Jan 2014 07:18:41 -0500
From: Jeff Layton <jlayton@poochiereds.net>
To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
Cc: NeilBrown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Jim Rees <rees@umich.edu>, linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: readdir vs. getattr
Message-ID: <20140129071841.1979a48c@tlielax.poochiereds.net>
In-Reply-To: <1342984553.746756.1390987303295.JavaMail.zimbra@desy.de>
References: <CAGue13pe_ZH_Eto-jL3mLjTNGFK26izTarnZdjs3eL82A2Z37w@mail.gmail.com>
	<20130404151507.GA8484@umich.edu>
	<CAGue13o6X5S3ppTX_fmMCTCX=7Mq_57YQEsb_hkOKwN9iOHwEQ@mail.gmail.com>
	<1365090480.10726.22.camel@leira.trondhjem.org>
	<20140129182532.7479eeda@notabene.brown>
	<1342984553.746756.1390987303295.JavaMail.zimbra@desy.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 29 Jan 2014 10:21:43 +0100 (CET)
"Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de> wrote:

> (without knowing kernel details)
> 
> What about some stat counter and trigger readdirplus instead of next getattr if
> some threshold are reached. Let say directory has more than 8000 entries and 
> getattr was called on 10% of the files. Of course you have to watch this per
> process.
> 
> Tigran.
> 

That might be the only possible solution, but as always with these
sorts of heuristics, it's bound to help some workloads and hurt others.

I'm not sure you'd need to watch that per-process. The pagecache data is
shared after all. The problem though is that you'd need to keep track
of which (or how many different) entries in the dir have gotten a
GETATTR since the last READDIRPLUS.

IOW, if someone is repeatedly hammering a single entry in a directory
with stat() calls that need the atime, you probably don't want to force
a READDIRPLUS on the next readdir() call. If however, they're stat'ing
each entry in the directory in turn for a "ls -l" type workload then
you probably do want to dump the cache and just go for a READDIRPLUS.

The real way to fix this is probably for someone to pick up and drive
the xstat()/readdirplus() work. If 'ls -l' used a readdirplus() syscall
to do its bidding then you'd have a pretty good idea of what you'd need
to do. That won't help in the short term though...

> ----- Original Message -----
> > From: "NeilBrown" <neilb@suse.de>
> > To: "Trond Myklebust" <trond.myklebust@primarydata.com>
> > Cc: "tigran mkrtchyan" <tigran.mkrtchyan@desy.de>, "Jim Rees" <rees@umich.edu>, "linux-nfs"
> > <linux-nfs@vger.kernel.org>
> > Sent: Wednesday, January 29, 2014 8:25:32 AM
> > Subject: Re: readdir vs. getattr
> > 
> > 
> > (resent with correct address for Trond)
> > 
> > On Thu, 4 Apr 2013 15:48:01 +0000 "Myklebust, Trond"
> > <Trond.Myklebust@netapp.com> wrote:
> > 
> > > On Thu, 2013-04-04 at 17:38 +0200, Tigran Mkrtchyan wrote:
> > > > On Thu, Apr 4, 2013 at 5:15 PM, Jim Rees <rees@umich.edu> wrote:
> > > > > Tigran Mkrtchyan wrote:
> > > > >
> > > > >   we have a directory with 50K (number of )  files in it.
> > > > >   The user does a 'ls' and I can see READDIR4. To
> > > > >   get the complete listing a client need to send ~380 requests.
> > > > >   Now user does yet another 'ls' in the same directory.
> > > > >   The client sends a GETATTR  on directorie's FH
> > > > >   (actually two of GETATTRS - why?!!) and discovers that a
> > > > >   directory didn't change and re-uses existing listing, BUT!!!
> > > > >   for each file in the directory it sends a GETATTR to discover
> > > > >   is  the file's attributes are changed. For 50K files it's a 50K
> > > > >   requests.
> > > > >
> > > > > So is this a "ls -l"? Because for "ls" it shouldn't stat all the files.
> > > > 
> > > > I believe it's 'ls -l'.  Well, you probably want to say that it's ls
> > > > calling stat on each file. Nevertheless client still should re-use
> > > > cached information.
> > > 
> > > What makes you think that it isn't using cached information? I'm
> > > guessing you just need to adjust the values of acregmin and acregmax
> > > upwards.
> > > 
> > > That said, we might be able to be a little more intelligent about how we
> > > use the NFS_INO_ADVISE_RDPLUS hint, and have it blow out the readdir
> > > cache when we find ourselves doing lots of lookup revalidates.
> > > 
> > 
> > Pop.
> > 
> > I recently had a customer raise exactly this issue with me, so I've been
> > looking into it.
> > 
> > I don't think it can really be fixed by adjusting acregmin/acregmax.
> > 
> > Once you have done READDIRPLUS, you have the directory contents in the
> > page-cache and will continue to use those contents until they drop out of the
> > cache, or until the directory changes in some way.
> > 
> > Meanwhile the stat information from the READDIRPLUS was used to create/update
> > info in the inode table and that will eventually become stale.  As soon as it
> > becomes stale you get a GETATTR storm on the next "ls -l" instead of a few
> > READDIRPLUS calls.  By increasing acregmin you can delay that storm, but you
> > can put it off forever.
> > 
> > Fixing this is tricky.  We really want to know on the first nfs_readdir()
> > call
> > whether it will be followed by lookups or not.  If it won't, then using the
> > cached data is fine.  If it will, then we really want a READDIRPLUS.
> > 
> > The only way I can see to address this is for nfs_advise_use_readdirplus  (or
> > code near where that is called) to notice that a readdir is currently active
> > on the same directory and is using cached data, and to re-use that 'open' of
> > the directory to do a readdirplus.  This would update the stat info for the
> > current inode and all the other inodes for the directory.
> > 
> > This is fairly horrible.  The 'struct file' used by the readdir would need to
> > be stored somewhere so that nfs_lookup_revalidate can use it (if process
> > permissions allow).  If multiple processes were doing a readdir at the same
> > time .... I would certainly get confused.
> > 
> > However I cannot think of anything else that would even come close to being a
> > real solution.
> > 
> > Any solution that just modified nfs_readdir() could only avoid the GETATTR
> > storm by largely ignoring the cached information and (almost) always calling
> > READDIRPLUS.
> > 
> > Does anyone have any other ideas?  Or do you think it is worth trying to
> > implement the above "horrible" idea.  I did start working on it, but only got
> > far enough to understand the full extend of what is required.
> > 
> > Thanks,
> > NeilBrown
> > 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Jeff Layton <jlayton@poochiereds.net>
