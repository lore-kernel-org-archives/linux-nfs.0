From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: RedHat Rawhide Kernels
Date: Thu, 8 Aug 2002 16:23:26 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020808162326.G28223@redhat.com>
References: <Pine.LNX.4.44.0208082017590.23326-100000@xpc1.ast.cam.ac.uk> <20020808153331.F28223@redhat.com> <shs65ylm7hp.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from to-velocet.redhat.com ([216.138.202.10] helo=touchme.toronto.redhat.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17ctog-0006KB-00
	for <nfs@lists.sourceforge.net>; Thu, 08 Aug 2002 13:23:30 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shs65ylm7hp.fsf@charged.uio.no>; from trond.myklebust@fys.uio.no on Thu, Aug 08, 2002 at 10:16:18PM +0200
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

On Thu, Aug 08, 2002 at 10:16:18PM +0200, Trond Myklebust wrote:
> Do you know offhand which set of patches are included?

# 15xx
# NFS patches: selected bits from Trond's 2.4.19pre8 patchset
#
Patch1501: linux-2.4.19-nfs-01-pathconf.dif.txt
Patch1503: linux-2.4.19-nfs-03-noac.dif.txt
Patch1504: linux-2.4.19-nfs-04-seekdir.dif.txt
Patch1505: linux-2.4.19-nfs-05-rdplus.dif.txt
Patch1506: linux-2.4.19-nfs-06-rpc_bkl.dif.txt
Patch1507: linux-2.4.19-nfs-07-bkl2.dif.txt
Patch1508: linux-2.4.19-nfs-08-rpc_cong.dif.txt
Patch1509: linux-2.4.19-nfs-09-rpc_wspace.dif.txt
Patch1510: linux-2.4.19-nfs-10-ping.dif.txt
Patch1511: linux-2.4.19-nfs-11-rpc_tweaks.dif.txt
Patch1520: linux-2.4.19-nfs-nosvc.patch
Patch1550: linux-2.4.18-nfs-default-size.patch

nosvc just silences the annoying unknown version (0) printk, and the 
default size patch reverts to a 4KB default if none is specified.

		-ben
-- 
"You will be reincarnated as a toad; and you will be much happier."


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
