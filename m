From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.4.19 hang (was unlink perf pb !)
Date: 14 Aug 2002 14:53:01 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsr8h1situ.fsf@charged.uio.no>
References: <8D7D56C6ED3DD411998D009027DC685E0874E22A@srv-grp-s1.segin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: "'Lever, Charles'" <Charles.Lever@netapp.com>,  nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17exeF-00054X-00
	for <nfs@lists.sourceforge.net>; Wed, 14 Aug 2002 05:53:15 -0700
To: Brasseur =?iso-8859-1?q?Val=E9ry?= <Valery.Brasseur@atosorigin.com>
In-Reply-To: <8D7D56C6ED3DD411998D009027DC685E0874E22A@srv-grp-s1.segin.com>
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

     > try a stock 2.4.19 without nfs patches : no hang !  seems that
     > nfs patches broke something !

Can you get me a trace of the hang using the command

   echo "1" > /proc/sys/sunrpc/rpc_debug

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
