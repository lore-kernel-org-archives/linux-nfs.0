From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: Stale file handle
Date: Mon, 3 Feb 2003 19:44:46 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030203194446.K3318@redhat.com>
References: <200302031903.53937.chris-nfs@drspirograph.com> <shslm0xcx68.fsf@charged.uio.no> <200302041044.45333.chris-nfs@drspirograph.com> <shsznpcopqe.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Jensen <chris-nfs@drspirograph.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from to-wiznet.redhat.com ([216.129.200.2] helo=touchme.toronto.redhat.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18frCn-0004Yn-00
	for <nfs@lists.sourceforge.net>; Mon, 03 Feb 2003 16:44:53 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shsznpcopqe.fsf@charged.uio.no>; from trond.myklebust@fys.uio.no on Tue, Feb 04, 2003 at 01:26:33AM +0100
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

On Tue, Feb 04, 2003 at 01:26:33AM +0100, Trond Myklebust wrote:
> What type of filesystem are you using on the server?

I've managed to trigger a stale file handle error by accessing a file on 
the server via a hardlink in a directory that is outside of the exported 
path on ext2...

		-ben
-- 
"Do you seek knowledge in time travel?"


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
