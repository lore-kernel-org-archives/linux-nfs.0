From: Ion Badulescu <ionut@cs.columbia.edu>
Subject: Re: Re: NFS retry on disconnection
Date: Tue, 14 May 2002 18:52:27 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200205142252.g4EMqRL00596@buggy.badula.org>
References: <shssn4vf8jo.fsf@charged.uio.no>
Cc: nfs@lists.sourceforge.net, Peter ?strand <astrand@lysator.liu.se>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from bgp401130bgs.jersyc01.nj.comcast.net ([68.36.96.125] helo=buggy.badula.org)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 177l9y-0001Mr-00
	for <nfs@lists.sourceforge.net>; Tue, 14 May 2002 15:52:46 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shssn4vf8jo.fsf@charged.uio.no>
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

On 14 May 2002 10:16:59 +0200, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> Nope. Major, minor, it all goes through the same code and both can be
> interrupted. What can happen, though, is that one process could
> actually be waiting on another process.

What I've noticed is that, more often than not, the hanging processes
end up waiting for rpciod. Sending a SIGKILL to rpciod unhangs those
processes, but unfortunately only root can do that...

Ion

-- 
  It is better to keep your mouth shut and be thought a fool,
            than to open it and remove all doubt.

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
