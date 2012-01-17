Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55511 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754401Ab2AQPS1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Jan 2012 10:18:27 -0500
Received: from bfields by fieldses.org with local (Exim 4.72)
	(envelope-from <bfields@fieldses.org>)
	id 1RnAnq-0003Vz-Jt
	for linux-nfs@vger.kernel.org; Tue, 17 Jan 2012 10:18:26 -0500
Date: Tue, 17 Jan 2012 10:18:26 -0500
To: linux-nfs@vger.kernel.org
Subject: Re: [PATCH/RFC 0/7] Volatile Filehandle Client-side Support
Message-ID: <20120117151826.GB12274@fieldses.org>
References: <1321056809.8733.2.camel@lade.trondhjem.org>
 <20111112144953.GA3740@infradead.org>
 <20111113145400.6c7a9be3@notabene.brown>
 <CAGue13r5BhjWOUF3L8Jd4_T0RmOwL7D=ktwHT_7paug5qEvKmA@mail.gmail.com>
 <20111113163632.GA28574@fieldses.org>
 <20111114080745.57083bfe@notabene.brown>
 <1321338825.8267.2.camel@lade.trondhjem.org>
 <20120113170914.GA31414@us.ibm.com>
 <20120114013834.GA20464@fieldses.org>
 <20120116165228.GA4990@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120116165228.GA4990@us.ibm.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 16, 2012 at 10:52:28AM -0600, Malahal Naineni wrote:
> J. Bruce Fields [bfields@fieldses.org] wrote:
> > On Fri, Jan 13, 2012 at 11:09:14AM -0600, Malahal Naineni wrote:
> > > Trond Myklebust [Trond.Myklebust@netapp.com] wrote:
> > > > On Mon, 2011-11-14 at 08:07 +1100, NeilBrown wrote:
> > > > 
> > > > > If a server has objects that are never renamed, it can easily use volatile
> > > > > file handles.
> > > > > If a server has objects which can be renamed and wants to use volatile file
> > > > > handles, then if such an object is open and is about to be renamed, it must
> > > > > first log to stable storage some mapping to allow it to access the file from
> > > > > the old volatile file handle.  And of course it cannot allow renames during
> > > > > the grace period, but I think we already have that.
> > > > > Also, if the VFH is such that it will be  lost on a reboot, the server must
> > > > > log it to stable storage before allowing an open.
> > > > 
> > > > BTW: If the namespace is stable, then the server can easily implement
> > > > permanent filehandles. Use a hash of the pathname as the filehandle, and
> > > > set up a hidden directory ('/.filehandles') containing symlinks that map
> > > > said hash back to the correct pathname. No need for volatile
> > > > filehandles.
> > > 
> > > Neil and Trond, one of our use cases is for a read only file system. The
> > > name space is stable and Volatile File Handle support should not have
> > > any issues under those conditions, correct?
> > 
> > Dumb question: remind me which filesystem your exporting that can't
> > already generate stable filehandles?
> 
> Only answers can be dumb! Bruce, we have ext3/ext4 file systems on two
> separate servers. The file systems are mirrored using rsync as and when
> needed. We would like to use the servers as replicas.

And why aren't you rsync'ing the underlying filesystem image instead?
Is that too slow?

> Since the file systems are mirrored using "rsync", the NFS file handles
> each server exports would be different. We would like to use volatile
> file handles feature of NFSv4 for this.

In theory the hidden directory for reverse lookups would work, but it
seems like it would be complicated to get right:
	- How do you generate the directory and keep it up to date?
	- What happens if somebody breaks the rules and updates the
	  filesystem while it's being exported?

Somehow it feels like there should be a simpler solution.

Maybe there would be other applications for that kind of
filehandle->file mapping, though, I don't know.

--b.
