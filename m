From: Ion Badulescu <ionut@cs.columbia.edu>
Subject: Re: 3 bugs with UDP mounts
Date: Tue, 23 Apr 2002 11:20:02 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200204231520.g3NFK2A04858@buggy.badula.org>
References: <5.0.2.1.0.20020422235308.02a960b0@pop.sfrn.dnai.com>
Cc: nfs@lists.sourceforge.net, "Lever, Charles" <Charles.Lever@netapp.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from bgp401130bgs.jersyc01.nj.comcast.net ([68.36.96.125] helo=buggy.badula.org)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17025W-0002ca-00
	for <nfs@lists.sourceforge.net>; Tue, 23 Apr 2002 08:20:14 -0700
To: Andrew Ryan <andrewr@nam-shub.com>
In-Reply-To: <5.0.2.1.0.20020422235308.02a960b0@pop.sfrn.dnai.com>
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

On Tue, 23 Apr 2002 00:37:15 -0700, Andrew Ryan <andrewr@nam-shub.com> wrote:

> Would it be possible -- via a kernel option or mount option -- to control 
> the behavior in the Linux client as well so that high performance can be 
> achieved on a Linux NFS client with high block sizes and UDP? Mixed 
> 100/1000 networks are becoming more of a reality and NFS/TCP, while having 
> gotten tremendously better in the last year or so, is still a work in 
> progress, and it's nice to have another acceptable option for mounting.
> 
> Solaris has clearly solved this problem somehow -- it would be nice if 
> linux could as well.

Are you absolutely sure that Solaris is mounting NFS/UDP? The reason I'm
asking is because Solaris' mount_nfs defaults to using TCP unless you
explicitly force it to use UDP with -o proto=udp.

Just checking...

Thanks,
Ion

-- 
  It is better to keep your mouth shut and be thought a fool,
            than to open it and remove all doubt.

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
