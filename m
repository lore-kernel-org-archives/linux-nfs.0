From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: KNFSD information  needed
Date: Fri, 2 May 2003 16:26:42 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200305021626.42933.bernd-schubert@web.de>
References: <002301c310aa$0ef33350$6e00a8c0@compaq3>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from relay.uni-heidelberg.de ([129.206.100.212])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19BbUy-0003xE-00
	for <nfs@lists.sourceforge.net>; Fri, 02 May 2003 07:26:52 -0700
To: "David Shirley" <dave@cs.curtin.edu.au>, <nfs@lists.sourceforge.net>
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

On Friday 02 May 2003 14:55, David Shirley wrote:
> Hi All,
>
> For a while now I was under the impression that nfsd provided with Redhat
> was the be all and end all, today after we had some fcntl locking issues it
> appears thats not the case.
>
> My first question is knfsd the same as the nfsd included in the nfs-utils
> package?

Hmm, knfsd consists of 2 parts, the kernel nfsd-module and nfs-utils rpc.nfsd.
So the answer should be yes.

 [snip]

>
> Sorry for these basic questions but the total lack of information online
> is quite shocking.

http://nfs.sourceforge.net/nfs-howto/


>
> Cheers
> Dave




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
