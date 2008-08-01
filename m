From: "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: [RFC] Reinstate NFS exportability for JFFS2.
Date: Fri, 1 Aug 2008 12:05:01 -0400
Message-ID: <76bd70e30808010905j3010a6bfy534c068a662d348d@mail.gmail.com>
References: <1209670979.25560.587.camel@pmac.infradead.org>
	 <18458.28833.539314.455215@notabene.brown>
	 <1217541264.1126.15.camel@shinybook.infradead.org>
	 <18578.21997.529551.676627@notabene.brown>
	 <1217551230.3719.15.camel@shinybook.infradead.org>
	 <76bd70e30807311753m2785c6d3kd82edd1fe8b5f8b7@mail.gmail.com>
	 <1217552437.3719.30.camel@shinybook.infradead.org>
	 <76bd70e30807311831p771d0f1eia3e303bd84919422@mail.gmail.com>
	 <1217597759.3454.356.camel@pmac.infradead.org>
	 <1217598976.3454.359.camel@pmac.infradead.org>
Reply-To: chucklever@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: viro@zeniv.linux.org.uk, "Neil Brown" <neilb@suse.de>,
	"Christoph Hellwig" <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-mtd@lists.infradead.org
To: "David Woodhouse" <dwmw2@infradead.org>,
	"J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1217598976.3454.359.camel@pmac.infradead.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi David-

On Fri, Aug 1, 2008 at 9:56 AM, David Woodhouse <dwmw2@infradead.org> wrote:
> On Fri, 2008-08-01 at 14:36 +0100, David Woodhouse wrote:
>> Those are needed by NFSv3 too -- and can be handled with a lookup_fh()
>> method in the file system which is guaranteed to be called from within
>> the filldir callback, and some support in the VFS for checking if it's a
>> mountpoint.
>>
>> NFSv4 introduces another problem though, which is that it seems to be
>> able to return the _full_ getattr() results for each object, and there's
>> no real way round the fact that we need to do the ->lookup() for that.
>>
>> If sane clients aren't expected to _ask_ for that, though, then perhaps
>> it would be OK to fall back to something like the existing
>> readdir-to-buffer hack for that case, while most normal clients won't
>> trigger it.

Sanity / insanity is probably not the right description for these
different types of clients... NFSv4 is designed to work with clients
that have a typical VFS (like an in-kernel Unix client), or user-space
clients, or clients on systems that don't have typical VFS APIs (like
Windows).  So, servers have to be prepared to expect a wide gamut of
different combinations of individual operations via compound RPCs.

In practice, nearly all client implementations so far are VFS-based
in-kernel clients, and have roughly the same kinds of readdir (ie
driven by getdents(3) and allowing seek offsets like a byte stream).
But they are at generally different stages of implementation, and have
different ways to go about their work.

However, speaking generally, the advanced features of NFSv4, like
FS_LOCATIONS and pseudofs often do require some special sauce that is
sometimes not terribly friendly to the server-side VFS.

I only mentioned that the Linux client doesn't use WORD0_FILEHANDLE to
caution against testing any server change with a Linux NFSv4 client --
it wouldn't necessarily exercise the server code in question.

Some NFSv3 clients don't support READDIRPLUS at all, while some can
disable it (like Linux, Mac OS, and FreeBSD), and others use it only
in certain cases (Linux).  I wouldn't describe any of these as saner
or more commonly encountered than another.

> Or maybe we could just mask the offending attrs out of ->rd_bmval for
> readdir calls, and say we don't support them? Would anyone scream if we
> did that?

I'm not an NFSv4 expert (hence my initial incorrect assertion about
NFSv4 not supporting readdirplus at all).  I defer to those who are
actually working on the standard and Linux implementation (Bruce?)
But typically masking out these features could potentially cause
severe interoperability problems for certain client implementations.
We can only know for sure after a lot of testing at multivendor events
like Connectathon; it's not something I would disable cavalierly.

I believe the server can also indicate to clients that NFSv3
READDIRPLUS is not supported, and that wouldn't cause as much of a
disaster for clients.  It would even be feasible to disable
READDIRPLUS only for certain physical file systems that would have a
problem with lookup-during-filldir.

I rather prefer making NFSD do the right thing here -- it seems to
localize and document the issue and provide a solution that all file
systems can use with a minimum of real fuss.

I know that OCFS2 has this locking inversion issue as well, and we
know OCFS2 users do share data from it with NFS.  So Oracle is
interested in a good solution here too.

-- 
Chuck Lever
