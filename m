From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfsd question
Date: 24 Apr 2002 09:26:12 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsr8l5tv57.fsf@charged.uio.no>
References: <CE1009281084264787C8D334D5BE259239A880@elsol.KNI-BA.kuokoa.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 170HAa-0006LC-00
	for <nfs@lists.sourceforge.net>; Wed, 24 Apr 2002 00:26:28 -0700
To: "Isaac Liu" <isaac@kuokoa.com>
In-Reply-To: <CE1009281084264787C8D334D5BE259239A880@elsol.KNI-BA.kuokoa.com>
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

>>>>> " " == Isaac Liu <isaac@kuokoa.com> writes:

     > hello, Is there a way to turn on debugging for nfsd?  I checked
     > the man page and it doesnt say so.  However, I've seen the nfsd
     > source with "dprintk()" function.

     > So there must be a way right?

It depends on what part of the code you want to debug, but in general
the approach would be to

echo <number>  >/proc/sys/sunrpc/nfsd_debug

A list of numbers can be found in include/linux/nfsd/debug.h. In
general, each number can enable debugging in one (or more) files in
fs/nfsd/*.c. To find out which number corresponds to which file,
grep for the value of NFSDDBG_FACILITY. In order to debug several
files simultaneously, you can 'or' the corresponding values of
NFSDDBG_FACILITY...

Cheers,
  Trond

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
