From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfs unlink perf !
Date: 12 Aug 2002 20:55:19 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shs65yfoqjs.fsf@charged.uio.no>
References: <8D7D56C6ED3DD411998D009027DC685E0874E214@srv-grp-s1.segin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17eKLc-0006DC-00
	for <nfs@lists.sourceforge.net>; Mon, 12 Aug 2002 11:55:25 -0700
To: Brasseur =?iso-8859-1?q?Val=E9ry?= <Valery.Brasseur@atosorigin.com>
In-Reply-To: <8D7D56C6ED3DD411998D009027DC685E0874E214@srv-grp-s1.segin.com>
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

>>>>> " " =3D=3D Brasseur Val=E9ry <Valery.Brasseur@atosorigin.com> writes:

     > I am testing an application which to a lot of link/unlink
     > server is a NetApp filer, client is linux 2.4.19+nfs patches.

     > under load it seems that the unlink call is very long when all
     > over calls response time seems to be OK.  is there any problems
     > with the unlink code ?

There should be no problems, but it depends on what type of test you
are doing...

The NFS protocol has to work around some nasty compatibility problems
w.r.t. the POSIX expected behaviour of unlink. In particular, POSIX
allows you to do

  open(file);
  write(file);
  unlink(file);
  read(file);
  close(file);

i.e. to unlink an open file...

In order for the above to work with NFS, one can't immediately unlink
the file when it is open(). Instead, NFS does a 'sillyrename': it
renames the file to something of the form .nfsXXXXX (where XXXX is
some number) and then performs the unlink when the 'close()' has been
performed.

Would this suffice to explain your 'bad performance'?

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
