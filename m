From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: mapping=file
Date: 09 Jul 2002 14:34:54 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsk7o5axld.fsf@charged.uio.no>
References: <003201c2273d$332d99b0$230d0dc3@Athlon>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17RuCv-0005Jz-00
	for <nfs@lists.sourceforge.net>; Tue, 09 Jul 2002 05:35:05 -0700
To: "Paolo Marini" <paolom@prisma-eng.it>
In-Reply-To: <003201c2273d$332d99b0$230d0dc3@Athlon>
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

>>>>> " " == Paolo Marini <paolom@prisma-eng.it> writes:

     > What is the undocumented mapping=file option for the exports
     > file ? There is nothing that tell me this, nor am I finding the
     > source code for the rpc.ugidd. I would like to know a way to
     > map client/server uid/gid without patching the kernel

As a search of the list archives would have told you: There is no such
way. rpc.ugidd was a program that was distributed with the userland
NFSv2 server unfsd.

There is currently no support for uid/gid mapping with knfsd.

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Stuff, things, and much much more.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
