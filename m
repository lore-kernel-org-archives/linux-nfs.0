From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: KNFSD information  needed
Date: 03 May 2003 15:08:05 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsk7d8i3ey.fsf@charged.uio.no>
References: <002301c310aa$0ef33350$6e00a8c0@compaq3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19BwkQ-0008AM-00
	for <nfs@lists.sourceforge.net>; Sat, 03 May 2003 06:08:14 -0700
To: "David Shirley" <dave@cs.curtin.edu.au>
In-Reply-To: <002301c310aa$0ef33350$6e00a8c0@compaq3>
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

>>>>> " " == David Shirley <dave@cs.curtin.edu.au> writes:

     > For a while now I was under the impression that nfsd provided
     > with Redhat

     > was the be all and end all, today after we had some fcntl
     > locking issues it
     > appears thats not the case.

Check the HOWTO and FAQ (see http://nfs.sourceforge.net/). Common NFS
locking problems are discussed there.

     > My first question is knfsd the same as the nfsd included in the
     > nfs-utils package?

No. knfsd is the generic name for the kernel NFS daemons. They reside
in kernel space. The nfsd and exportfs that included in the nfs-utils
package are just user controls for those daemons.

     > Secondly If its not how do I go about using knfsd over the
     > stock nfsd?

man nfsd

     > Sorry for these basic questions but the total lack of
     > information online is quite shocking.

The NFS FAQ and HOWTO are both run by volunteers. If you think they
are incomplete, then feel free to offer to help write better ones.

Feel free too to browse the archives of this mailing list...

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
