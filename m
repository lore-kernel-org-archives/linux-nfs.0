From: Steve Dickson <SteveD@redhat.com>
Subject: Re: A Question about the 2.4.21 Pathconf patch
Date: Tue, 29 Apr 2003 14:41:56 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EAEC774.20402@RedHat.com>
References: <3EAE956E.9080205@RedHat.com> <shs4r4h5l52.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from nat-pool-rdu.redhat.com ([66.187.233.200] helo=lacrosse.corp.redhat.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Aa3H-0007XQ-00
	for <nfs@lists.sourceforge.net>; Tue, 29 Apr 2003 11:42:03 -0700
Received: from RedHat.com (dickson.boston.redhat.com [172.16.65.20])
	by lacrosse.corp.redhat.com (8.11.6/8.9.3) with ESMTP id h3TIfuV08807
	for <nfs@lists.sourceforge.net>; Tue, 29 Apr 2003 14:41:56 -0400
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

Hello Trond,

Trond Myklebust wrote:

>Why would we want to succeed in that case? If the server operates with
>some screwed up set of parameters that we are incapable of supporting,
>surely the best thing to do is to fail immediately?
>
Very true... I think we are saying the same thing.... Maybe I
was not too clear....

>Note: Most of the functionality of NFSPROC3_FSINFO *is* in fact in v2,
>but it is either part of NFSPROC_STATFS, or (shudder) has been tacked
>onto the mount protocol.
>
Right... but with the difference being that statfs supplies dynamic
information and fsinfo supplies static info. And some the
fsinfo info, like readdir sizes, procedures not supported,
max reads/writes sizes along with preferred read/write sizes
seems like good information to have about the server, although
not totally necessary, obviously ;-)

So I'm just curious, why (from a protocol purest standpoint) its
not being used... and if it ever was used, what were the results...

SteveD.



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
