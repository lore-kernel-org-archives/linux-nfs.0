Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34354 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751786Ab1KNAnH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 13 Nov 2011 19:43:07 -0500
Date: Sun, 13 Nov 2011 19:42:54 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>,
        Christoph Hellwig <hch@infradead.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Matthew Treinish <treinish@linux.vnet.ibm.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH/RFC 0/7] Volatile Filehandle Client-side Support
Message-ID: <20111114004254.GA30681@fieldses.org>
References: <1321052673-22171-1-git-send-email-treinish@linux.vnet.ibm.com>
 <1321056809.8733.2.camel@lade.trondhjem.org>
 <20111112144953.GA3740@infradead.org>
 <20111113145400.6c7a9be3@notabene.brown>
 <CAGue13r5BhjWOUF3L8Jd4_T0RmOwL7D=ktwHT_7paug5qEvKmA@mail.gmail.com>
 <20111113163632.GA28574@fieldses.org>
 <20111114080745.57083bfe@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111114080745.57083bfe@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 14, 2011 at 08:07:45AM +1100, NeilBrown wrote:
> On Sun, 13 Nov 2011 11:36:32 -0500 "J. Bruce Fields" <bfields@fieldses.org>
> wrote:
> 
> > On Sun, Nov 13, 2011 at 02:45:48PM +0100, Tigran Mkrtchyan wrote:
> > > I have a server which runs on top of hadoop. The problem with hadoop
> > > is that there is no way to have persistent file handles. I am
> > > currently working on a way to do that - either simulate them or add a
> > > support for unique file id to hadoop. If linux client will support
> > > volatile file handles then I can stop inventing some workarounds.
> > 
> > I might call that "fixing" rather than inventing workarounds.
> > 
> > Our of curiosity: if we really wanted to support such filesystems, what
> > would we need in the protocol?  Just saying "filehandles aren't stable,
> > deal with it" seems insufficient. 
> 
> 1/ no guarantees if the file is not 'open'
> 2/ two possible responses to FHEXPIRED:
>     a/ perform a GETATTR and request the 'filehandle' attribute.  Client then
>        uses that filehandle instead.
>     b/ perform LOOKUP on parent filehandle with same name as before, and use
>        the resulting filehandle.
>    Server specifies which somehow (different error code?  magic attribute
>    flag somewhere?  doesn't really matter)
> 
> If a server has objects that are never renamed, it can easily use volatile
> file handles.
> If a server has objects which can be renamed and wants to use volatile file
> handles, then if such an object is open and is about to be renamed, it must
> first log to stable storage some mapping to allow it to access the file from
> the old volatile file handle.

I think then there's no limit to the lifetime of those log entries, or
to the size of the log?

--b.

> And of course it cannot allow renames during
> the grace period, but I think we already have that.
> Also, if the VFH is such that it will be  lost on a reboot, the server must
> log it to stable storage before allowing an open.


