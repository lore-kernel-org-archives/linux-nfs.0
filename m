From: Tom McNeal <trmcneal@attbi.com>
Subject: Re: NFS utils package, and an fsx question
Date: Mon, 13 May 2002 08:23:49 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3CDFDA85.CA8F6258@attbi.com>
References: <3CDF247A.E7106AA4@attbi.com> <shsr8kgd301.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS maillist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from rwcrmhc54.attbi.com ([216.148.227.87])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 177Hdu-0006RA-00
	for <nfs@lists.sourceforge.net>; Mon, 13 May 2002 08:21:42 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

What I see is this:

 - The tests fail most often when they are the only tests 
running, and nothing else is going on.  Generally, when I'm
doing the test run, I have all tests running 500 times, 
and I might see 2 or 3 of these failures.

 - The special tests fail with this error:

--
SPECIAL TESTS: directory /mnt/first/usr/local/NFSTest
mkdir: cannot create directory `/mnt/first/usr/local/NFSTest': File exists
cd /mnt/first/usr/local/NFSTest; rm -f runtests runtests.wrk READWIN.txt
Makefile op_unlk op_ren op_chmod dupreq excltest negseek rename holey truncate
nfsidem nstat stat stat2 touchn fstat rewind telldir bigfile bigfile2 freesp
cp runtests runtests.wrk READWIN.txt Makefile op_unlk op_ren op_chmod dupreq
excltest negseek rename holey truncate nfsidem nstat stat stat2 touchn fstat
rewind telldir bigfile bigfile2 freesp /mnt/first/usr/local/NFSTest
runtests.wrk: runtests.wrk: No such file or directory
special tests failed
--

 - The general tests fail with this error:

--
GENERAL TESTS: directory /mnt/first/usr/local/NFSTest
mkdir: cannot create directory `/mnt/first/usr/local/NFSTest': File exists
cd /mnt/first/usr/local/NFSTest; rm -f Makefile runtests runtests.wrk *.sh *.c
mkdummy rmdummy nroff.in makefile.tst
cp Makefile runtests runtests.wrk *.sh *.c mkdummy rmdummy nroff.in makefile.tst
/mnt/first/usr/local/NFSTest

Small Compile
runtests.wrk: line 85: unexpected EOF while looking for matching `"'
runtests.wrk: line 88: syntax error: unexpected end of file
general tests failed
--

I think the issue is distructive interaction between the two
tests, since I am running them in tandem, rather than in
succession, as is done normally.  They generally fail together,
either once or twice each, and then start completing successfully
again.  

Tom


Trond Myklebust wrote:
> 
> >>>>> " " == Tom McNeal <trmcneal@attbi.com> writes:
> 
>      > The tests consist of the 4 2002 Connectathon tests suites
>      > (basic, general, special, and lock), fsx, a duplicate request
>      > cache exerciser, and bonnie++, all running simultaneously
>      > overnight.  I tested a 2.4.18 and 2.2.19 UP client against
>      > 2.4 and 2.2 UP servers.  The failure rate was less than 1%,
>      > primarily due to interaction between special and general tests
>      > that I haven't quite figured out yet.
> 
> Any details on the failures? 2.4.18 was tested extensively at Cthon
> with no problems being observed...
> 
> Cheers,
>   Trond

--
------------------------------------------------------------
Tom McNeal       trmcneal@attbi.com     (650)906-0761 (cell) 
------------------------------------------------------------

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
