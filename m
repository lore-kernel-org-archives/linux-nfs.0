Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41657 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751465Ab2ANBiy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 20:38:54 -0500
Date: Fri, 13 Jan 2012 20:38:34 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>, NeilBrown <neilb@suse.de>,
        Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>,
        Christoph Hellwig <hch@infradead.org>,
        Matthew Treinish <treinish@linux.vnet.ibm.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH/RFC 0/7] Volatile Filehandle Client-side Support
Message-ID: <20120114013834.GA20464@fieldses.org>
References: <1321052673-22171-1-git-send-email-treinish@linux.vnet.ibm.com>
 <1321056809.8733.2.camel@lade.trondhjem.org>
 <20111112144953.GA3740@infradead.org>
 <20111113145400.6c7a9be3@notabene.brown>
 <CAGue13r5BhjWOUF3L8Jd4_T0RmOwL7D=ktwHT_7paug5qEvKmA@mail.gmail.com>
 <20111113163632.GA28574@fieldses.org>
 <20111114080745.57083bfe@notabene.brown>
 <1321338825.8267.2.camel@lade.trondhjem.org>
 <20120113170914.GA31414@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120113170914.GA31414@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 13, 2012 at 11:09:14AM -0600, Malahal Naineni wrote:
> Trond Myklebust [Trond.Myklebust@netapp.com] wrote:
> > On Mon, 2011-11-14 at 08:07 +1100, NeilBrown wrote:
> > 
> > > If a server has objects that are never renamed, it can easily use volatile
> > > file handles.
> > > If a server has objects which can be renamed and wants to use volatile file
> > > handles, then if such an object is open and is about to be renamed, it must
> > > first log to stable storage some mapping to allow it to access the file from
> > > the old volatile file handle.  And of course it cannot allow renames during
> > > the grace period, but I think we already have that.
> > > Also, if the VFH is such that it will be  lost on a reboot, the server must
> > > log it to stable storage before allowing an open.
> > 
> > BTW: If the namespace is stable, then the server can easily implement
> > permanent filehandles. Use a hash of the pathname as the filehandle, and
> > set up a hidden directory ('/.filehandles') containing symlinks that map
> > said hash back to the correct pathname. No need for volatile
> > filehandles.
> 
> Neil and Trond, one of our use cases is for a read only file system. The
> name space is stable and Volatile File Handle support should not have
> any issues under those conditions, correct?

Dumb question: remind me which filesystem your exporting that can't
already generate stable filehandles?

--b.

> 
> Trond, trying to understand how we can make file handles permanent at
> the servers with your ideas. We do use linux NFS server. Looks like the
> server needs a new config parameter to hide '/.filehandles' and use it
> for storing permanent file handles. Also, the solution needs a tool
> that generates/populates './filehandles' directory. I don't know how
> best we should handle hash collisions at this point (shouldn't be an
> issue once we agree to a method though). Anything else I am missing?
> 
> Any thoughts from linux NFS server community? Is this approach
> acceptable?
> 
> Regards, Malahal.
> 
