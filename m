From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: RE: Stale mounts - very nasty
Date: Wed, 14 May 2003 19:05:59 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16066.30583.224225.946035@charged.uio.no>
References: <5CA6F03EF05E0046AC5594562398B916A3293A@POEXMB3.conoco.net>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Trond Myklebust" <trond.myklebust@fys.uio.no>,
    <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Fzhf-0004De-00
	for <nfs@lists.sourceforge.net>; Wed, 14 May 2003 10:06:07 -0700
To: "Heflin, Roger A." <Roger.A.Heflin@conocophillips.com>
In-Reply-To: <5CA6F03EF05E0046AC5594562398B916A3293A@POEXMB3.conoco.net>
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

>>>>> " " == Roger A Heflin <Heflin> writes:

     > If the Sun server export case is wrong, the Sun clients seems
     > to still retry after it gets a stale, as the sun clients have
     > been comfirmed to have received the stale message, but
     > recovered without intervention by any admins, or a reboot.  Can
     > anyone else comfirm that this appears to be the case?  This is
     > with Solairs 8.

They probably do.

I'm more careful because there are still servers which are not safe
when it comes to the issue of filehandle reuse (in particular there
are people who still insist on using the userspace nfs daemon).  On
such a server, the fact that a filehandle is suddenly accepted again
does not necessarily imply that we are accessing the same file (or
even the same type of file).

Cheers,
  Trond


-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
