From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: RE: linux 2.4.20 oops
Date: Tue, 29 Apr 2003 19:21:42 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16046.46246.873977.442835@charged.uio.no>
References: <6440EA1A6AA1D5118C6900902745938E07D5559A@black.eng.netapp.com>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Lever, Charles" <Charles.Lever@netapp.com>,
    NFS maillist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19AYoB-0007ni-00
	for <nfs@lists.sourceforge.net>; Tue, 29 Apr 2003 10:22:23 -0700
To: Marcelo Tosatti <marcelo@conectiva.com.br>
In-Reply-To: <6440EA1A6AA1D5118C6900902745938E07D5559A@black.eng.netapp.com>
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

>>>>> " " == Charles Lever <Lever> writes:

     > i built 2.4.21-rc1 from 2.4.20.tar.bz2 and the rc1 upgrade
     > patch, and its not in my version of rc1.

Hmmm... strange. AFAICS there are no NFS or RPC changes whatsoever in
the rc1 patch on ftp.kernel.org.
As I said, all the changes (including Ulrich Weigand's patch) appear
to still be in the bitkeeper repository (see for instance the kernel
source browser on http://linux.bkbits.net:8080/linux-2.4).

Marcelo, is this perhaps a problem with an incorrect generation of the
'official' 2.4.21-rc1 patch?

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
