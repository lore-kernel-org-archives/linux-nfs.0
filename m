From: Chris Mason <chris.mason@oracle.com>
Subject: Re: [patch 0/9] writeback data integrity and other fixes (take 3)
Date: Wed, 29 Oct 2008 10:56:36 -0400
Message-ID: <1225292196.6448.263.camel@think.oraclecorp.com>
References: <20081028144715.683011000@suse.de>
	 <20081028153953.GB3082@wotan.suse.de> <20081028222746.GB4985@disturbed>
	 <20081029001653.GF15599@wotan.suse.de> <20081029031645.GE4985@disturbed>
	 <20081029091203.GA32545@infradead.org>
	 <20081029092143.GA5953@wotan.suse.de>
	 <20081029094417.GA21824@infradead.org>
	 <20081029103029.GC5953@wotan.suse.de> <20081029122234.GE846@shareable.org>
	 <490865E3.8070102@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Jamie Lokier <jamie@shareable.org>, Nick Piggin <npiggin@suse.de>,
	Christoph Hellwig <hch@infradead.org>,
	linux-nfs@vger.kernel.org, akpm@linux-foundation.org,
	xfs@oss.sgi.com, linux-fsdevel@vger.kernel.org
To: Ric Wheeler <ricwheeler@gmail.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <490865E3.8070102@gmail.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2008-10-29 at 09:32 -0400, Ric Wheeler wrote:
> Jamie Lokier wrote:

> >> Is there anything that particularly makes it a file operation
> >> as opposed to an inode operation?
> >>     
> >
> > In principle, is fsync() required to flush all dirty data written
> > through any file descriptor ever, or just dirty data written through
> > the file descriptor used for fsync()?
> >
> > -- Jamie
> > --
> >   
> http://www.opengroup.org/onlinepubs/009695399/functions/fsync.html
> 
> Is a pointer to what seems to be the official posix spec for this - it 
> is definitely per file descriptor, not per file system, etc...
> 

Maybe I'm reading Jamie's question wrong, but I think he's saying:

/* open exactly the same file twice */
fd = open("file");
fd2 = open("file");

write(fd, "stuff")
write(fd2, "more stuff")
fsync(fd);

Does the fsync promise "more stuff" will be on disk?  I think the answer
should be yes.

-chris


