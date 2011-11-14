Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:19210 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751826Ab1KNR1K convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Nov 2011 12:27:10 -0500
Message-ID: <1321291627.2632.49.camel@lade.trondhjem.org>
Subject: Re: [PATCH/RFC 0/7] Volatile Filehandle Client-side Support
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: NeilBrown <neilb@suse.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>,
        Christoph Hellwig <hch@infradead.org>,
        Matthew Treinish <treinish@linux.vnet.ibm.com>,
        linux-nfs@vger.kernel.org
Date: Mon, 14 Nov 2011 19:27:07 +0200
In-Reply-To: <20111114080745.57083bfe@notabene.brown>
References: <1321052673-22171-1-git-send-email-treinish@linux.vnet.ibm.com>
	 <1321056809.8733.2.camel@lade.trondhjem.org>
	 <20111112144953.GA3740@infradead.org>
	 <20111113145400.6c7a9be3@notabene.brown>
	 <CAGue13r5BhjWOUF3L8Jd4_T0RmOwL7D=ktwHT_7paug5qEvKmA@mail.gmail.com>
	 <20111113163632.GA28574@fieldses.org>
	 <20111114080745.57083bfe@notabene.brown>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2011-11-14 at 08:07 +1100, NeilBrown wrote: 
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

Question: Section 8.11 states that

   When the server chooses to export multiple filehandles corresponding
   to the same file object and returns different filehandles on two
   different OPENs of the same file object, the server MUST NOT "OR"
   together the access and deny bits and coalesce the two open files.
   Instead the server must maintain separate OPENs with separate
   stateids and will require separate CLOSEs to free them.

How does one reconcile the above paragraph with a case where the server
can expire a filehandle while the file is open? For one thing, it seems
to say that you cannot CLOSE (or unlock!) a file once the filehandle
expires...

> a/ perform a GETATTR and request the 'filehandle' attribute.  Client then
>        uses that filehandle instead.

??? GETATTR takes a filehandle argument and will presumably get an
automatic FHEXPIRED. If not, and if you can map one filehandle into
another, then why do you need the second filehandle?

If the issue is that the mapping is expensive then what stops you from
caching the first filehandle for the duration of the file being open?

> b/ perform LOOKUP on parent filehandle with same name as before, and use
>        the resulting filehandle.
>    Server specifies which somehow (different error code?  magic attribute
>    flag somewhere?  doesn't really matter)

How do I know this is the same file?

> If a server has objects that are never renamed, it can easily use volatile
> file handles.

How do you deal with unlink("foo") followed by create("foo")? The spec
says that the server is free to return FHEXPIRED in this case too.

> If a server has objects which can be renamed and wants to use volatile file
> handles, then if such an object is open and is about to be renamed, it must
> first log to stable storage some mapping to allow it to access the file from
> the old volatile file handle.  And of course it cannot allow renames during
> the grace period, but I think we already have that.
> Also, if the VFH is such that it will be  lost on a reboot, the server must
> log it to stable storage before allowing an open.
> 
> > 
> > Say there was some way for the client to indicate which filehandles it
> > currently has in use, and some way for the server to ask the client to
> > return in-use filehandles if there are too many (like DELEG_RECALL_ANY).
> > Then the server could at least place a limit on the number of
> > filehandles that it had to guarantee persistent.
> > 
> > And/or the client could get a callback on rename/link/unlink.  Bah.
> > 
> > Would any of that actually be easier than implementing persistent file
> > handles?
> 
> Easier for whom?  Should NFSv4 be designed to make life easier for filesystem
> implementers, or easier for NFS implementers :-?
> 
> While I don't have concrete examples I would not be surprised if there were
> filesystems where implementing limited persistence was practical while
> implementing universal persistence was not.

The question is why would we need to support exporting such filesystems
over NFS?

The thing to note is that not everything in the NFSv4 spec is actually
useful. A lot of it is "it seemed like a good idea a the time" material
and is recognisably incompletely thought through (volatile filehandles
being a major case in point). That's why we need to 

     A. demand very concrete use-cases with very real reasons for why
        there is no alternative 
     B. make sure that we work out the spec details before attempting
        implementations.

Trond

Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

