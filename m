From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Questions about NFS over TCP
Date: Thu, 24 Apr 2003 08:23:53 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EA7D759.5000101@RedHat.com>
References: <3EA66B58.2B1E4A45@moving-picture.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from nat-pool-rdu.redhat.com ([66.187.233.200] helo=lacrosse.corp.redhat.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 198fhv-0008LS-00
	for <nfs@lists.sourceforge.net>; Thu, 24 Apr 2003 05:20:07 -0700
Received: from RedHat.com (dickson.boston.redhat.com [172.16.65.20])
	by lacrosse.corp.redhat.com (8.11.6/8.9.3) with ESMTP id h3OCK0V05916
	for <nfs@lists.sourceforge.net>; Thu, 24 Apr 2003 08:20:00 -0400
To: nfs@lists.sourceforge.net
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

James Pearson wrote:

>I've just started experimenting with NFS over TCP and have a few
>  
>
I too have started working with NFS over TCP and the only
problem I've seen so far is with flow control on the server
side...

Running the fstress benchmark locks ups NFSD tighter than
a drum in a matter of seconds... Now this probably has to
do with way that fstress sends its rpcs. Its seems to
"piggy-back" a bunch of messages in one TCP stream (meaning
ethereal show multiple rpcs in one tcp frame) which
is far from "normal" traffic. But it does hang the
which makes it very hard to get any of timings...

SteveD.



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
