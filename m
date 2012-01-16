Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e4.ny.us.ibm.com ([32.97.182.144]:38379 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754778Ab2APR7u (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Jan 2012 12:59:50 -0500
Received: from /spool/local
	by e4.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Mon, 16 Jan 2012 12:59:50 -0500
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 3DB4C38C9927
	for <linux-nfs@vger.kernel.org>; Mon, 16 Jan 2012 11:52:35 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q0GGqUTa2269358
	for <linux-nfs@vger.kernel.org>; Mon, 16 Jan 2012 11:52:31 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q0GGqTHs013217
	for <linux-nfs@vger.kernel.org>; Mon, 16 Jan 2012 14:52:29 -0200
Received: from malahal (malahal.austin.ibm.com [9.53.40.203])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id q0GGqTbv013183
	for <linux-nfs@vger.kernel.org>; Mon, 16 Jan 2012 14:52:29 -0200
Date: Mon, 16 Jan 2012 10:52:28 -0600
From: Malahal Naineni <malahal@us.ibm.com>
To: linux-nfs@vger.kernel.org
Subject: Re: [PATCH/RFC 0/7] Volatile Filehandle Client-side Support
Message-ID: <20120116165228.GA4990@us.ibm.com>
References: <1321052673-22171-1-git-send-email-treinish@linux.vnet.ibm.com>
 <1321056809.8733.2.camel@lade.trondhjem.org>
 <20111112144953.GA3740@infradead.org>
 <20111113145400.6c7a9be3@notabene.brown>
 <CAGue13r5BhjWOUF3L8Jd4_T0RmOwL7D=ktwHT_7paug5qEvKmA@mail.gmail.com>
 <20111113163632.GA28574@fieldses.org>
 <20111114080745.57083bfe@notabene.brown>
 <1321338825.8267.2.camel@lade.trondhjem.org>
 <20120113170914.GA31414@us.ibm.com>
 <20120114013834.GA20464@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120114013834.GA20464@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields [bfields@fieldses.org] wrote:
> On Fri, Jan 13, 2012 at 11:09:14AM -0600, Malahal Naineni wrote:
> > Trond Myklebust [Trond.Myklebust@netapp.com] wrote:
> > > On Mon, 2011-11-14 at 08:07 +1100, NeilBrown wrote:
> > > 
> > > > If a server has objects that are never renamed, it can easily use volatile
> > > > file handles.
> > > > If a server has objects which can be renamed and wants to use volatile file
> > > > handles, then if such an object is open and is about to be renamed, it must
> > > > first log to stable storage some mapping to allow it to access the file from
> > > > the old volatile file handle.  And of course it cannot allow renames during
> > > > the grace period, but I think we already have that.
> > > > Also, if the VFH is such that it will be  lost on a reboot, the server must
> > > > log it to stable storage before allowing an open.
> > > 
> > > BTW: If the namespace is stable, then the server can easily implement
> > > permanent filehandles. Use a hash of the pathname as the filehandle, and
> > > set up a hidden directory ('/.filehandles') containing symlinks that map
> > > said hash back to the correct pathname. No need for volatile
> > > filehandles.
> > 
> > Neil and Trond, one of our use cases is for a read only file system. The
> > name space is stable and Volatile File Handle support should not have
> > any issues under those conditions, correct?
> 
> Dumb question: remind me which filesystem your exporting that can't
> already generate stable filehandles?

Only answers can be dumb! Bruce, we have ext3/ext4 file systems on two
separate servers. The file systems are mirrored using rsync as and when
needed. We would like to use the servers as replicas.

Since the file systems are mirrored using "rsync", the NFS file handles
each server exports would be different. We would like to use volatile
file handles feature of NFSv4 for this.

Hope that helps.

Regards, Malahal.

