From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: max memory size on input queue?
Date: 04 Jun 2003 19:33:35 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shs1xy9928g.fsf@charged.uio.no>
References: <3EDE192D.4000602@motorola.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19NcPp-0007vU-00
	for <nfs@lists.sourceforge.net>; Wed, 04 Jun 2003 10:51:13 -0700
To: Tom Georgoulias <tom.georgoulias@motorola.com>
In-Reply-To: <3EDE192D.4000602@motorola.com>
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

>>>>> " " == Tom Georgoulias <tom.georgoulias@motorola.com> writes:

     > Is there any agreement on what is the safest, largest input
     > queue memory size?  /etc/syconfig/nfs has an option to turn
     > this value to 256k, so it that generally the best setting to
     > use?  What about 512k?

See the discussion in the NFS-HOWTO.

Cheers,
 Trond


-------------------------------------------------------
This SF.net email is sponsored by:  Etnus, makers of TotalView, The best
thread debugger on the planet. Designed with thread debugging features
you've never dreamed of, try TotalView 6 free at www.etnus.com.
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
