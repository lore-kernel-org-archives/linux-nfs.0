From: Erik Thiele <erik@thiele-hydraulik.de>
Subject: Re: trouble with file locking
Date: Thu, 20 Nov 2003 07:49:57 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20031120074957.6f1a95d5.erik@thiele-hydraulik.de>
References: <20031112105043.020c1548.erik@thiele-hydraulik.de>
	<Pine.LNX.4.58.0311191259400.846@lewis.et.byu.edu>
	<shsd6bohzxw.fsf@charged.uio.no>
	<20031120070531.7886de98.erik@thiele-hydraulik.de>
	<16316.23490.266052.855506@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davidd@et.byu.edu, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AMieJ-0004bl-00
	for <nfs@lists.sourceforge.net>; Wed, 19 Nov 2003 22:50:43 -0800
Received: from moutng.kundenserver.de ([212.227.126.186])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1AMidf-0004Za-6B
	for nfs@lists.sourceforge.net; Wed, 19 Nov 2003 22:50:03 -0800
To: trond.myklebust@fys.uio.no
In-Reply-To: <16316.23490.266052.855506@charged.uio.no>
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

On Thu, 20 Nov 2003 01:14:26 -0500
Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> >>>>> " " == Erik Thiele <erik@thiele-hydraulik.de> writes:
> 
>     >> flock() doesn't work at all over NFS in Linux. It just does
>     >> local locking.
> 
>      > well, but i saw ethereal showimg me the nfs locking packets.
> 
> Then you have been using POSIX locks (i.e. fcntl()/lockf()). They
> should work fine.

from my original mail:


int main()
{
  int h=open("delmelockfile", O_WRONLY|O_CREAT, 0700);
  struct flock l;
  memset(&l,0,sizeof l);
  l.l_type=F_WRLCK;
  l.l_whence=SEEK_SET;
  l.l_start=0;
  l.l_len=0;
  fcntl(h,F_SETLK,&l);
  sleep(100);
  return 0;
}

> 
> 
> I agree, though, with David's assertion that the fact you are running
> against HP-UX may be significant. They have historically had a
> reputation for a poor implementation of the NFS lock manager protocol.
> 

from my original mail:

i am exporting to old hp-ux machines a subdirectory of / like this:
/Archiv xxx.unix.yyy-intern(rw,no_root_squash)

i also export my homedirectory to my linux woody debian machines like
this:
/home/erik str.blafoo-intern(rw,no_root_squash)


.. so the question is, can different exports interfere with each other
with locking???

can one lock files on a readonly export? (then this would be a security
problem, because if i mount an anonymous readonly export with hp-ux, the
other exports will fail to lock.


again, what i don't understand is that a restart of the statd daemon
fixes the problem forever.



cu
erik

-- 
Erik Thiele


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
