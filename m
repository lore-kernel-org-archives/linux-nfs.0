From: Joe Landman <landman@scalableinformatics.com>
Subject: Re: network storage solutions
Date: 15 May 2003 14:56:25 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1053024984.5960.28.camel@squash.scalableinformatics.com>
References: <1053018023.2883.168.camel@protein.scalableinformatics.com>
	 <3EC3D370.5050406@lmco.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Beowulf <beowulf@beowulf.org>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from dsl093-000-201.det1.dsl.speakeasy.net ([66.93.0.201] helo=crunch.scalableinformatics.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19GNu9-0000FX-00
	for <nfs@lists.sourceforge.net>; Thu, 15 May 2003 11:56:37 -0700
To: jeffrey.b.layton@lmco.com
In-Reply-To: <3EC3D370.5050406@lmco.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Thu, 2003-05-15 at 13:50, Jeff Layton wrote:

>    Since we use our cluster for production work (please, I'm
> not trying to offend anyone), we HAVE to have non-corrupted
> data. This is why we use hard mounts with 'sync' as well as
> a few other options. The URL above to Chuck's paper has
> several examples of "good" mount options.

Hmmm.  I am reasonably sure that when the IO system returns an error, it
does in fact get propagated to the appropriate user-land calling
program.  The program then makes the determination as to whether or not
to continue.  There are quite a few programs that rarely inspect return
code from file operations.  If you really require uncorrupted data, then
you are probably using the synchronous/unbuffered file writes anyway
(the O_SYNC, and possibly O_DIRECT options, though NFS has experimental
support for O_DIRECT from reading the note around Trond's patches).

> > The way I and other who use soft mounts view it, data lossage occurs
> > when the server crashes, as you cannot guarantee (except with sync),
> > that the data was committed to disk.
> >
> 
> However, if I read Chuck's paper correctly, with soft mount
> you can get a soft time-out that can interrupt an operation
> but the client will continue then with corrupted data. Am I
> understanding this correctly? Therefore, the clients may be
> up, but now the data is corrupt and the appliation doesn't
> know it.

I would like to know that as well.  I would like to believe it will not
continue with corrupt data, but return an error code/condition which
should be handled.

[...]

> I'm not sure... If the server crashes, I think this is true.
> But what if you get an interrupt. Soft mounts will allow
> the application to continue with corrupted data while hard
> mounts will produce an error, but not corrupt data (I think).

I hope not.  The programs that I send an INTR to on an NFS system (with
the intr flag allowed) seem to accept the signal and die.  I guess the
question is here, what should be the state of the filesystem upon
acceptance of that signal?  Can you assume it is in a known state?


-- 
Joseph Landman, Ph.D
Scalable Informatics LLC,
email: landman@scalableinformatics.com
web  : http://scalableinformatics.com
phone: +1 734 612 4615



-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
