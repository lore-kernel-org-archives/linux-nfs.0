From: Andrew Ryan <andrewr@nam-shub.com>
Subject: Re: v3/tcp mounts occasionally hang for 10+ minutes
Date: Tue, 02 Apr 2002 06:35:48 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5.0.2.1.0.20020402063452.0284bec0@pop.sfrn.dnai.com>
References: <5.0.2.1.0.20020401235131.0285bb00@pop.sfrn.dnai.com>
 <5.0.2.1.0.20020401235131.0285bb00@pop.sfrn.dnai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Cc: nfs@lists.sourceforge.net
Received: from barney.sfrn.dnai.com ([208.59.199.24])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16sQS3-00088W-00
	for <nfs@lists.sourceforge.net>; Tue, 02 Apr 2002 07:44:03 -0800
Received: from sideshow-mel.sfrn.dnai.com (sideshow-mel.sfrn.dnai.com [208.59.199.19])
	by barney.sfrn.dnai.com (8.11.2/8.11.2) with ESMTP id g32FgJ887860
	for <nfs@lists.sourceforge.net>; Tue, 2 Apr 2002 07:42:19 -0800 (PST)
To: nfs@lists.sourceforge.net
In-Reply-To: <shshemuijkd.fsf@charged.uio.no>
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

At 10:36 AM 4/2/02 +0200, Trond Myklebust wrote:

>If the OOM killer is signalling the rpciod process, then that could
>indeed cause the sort of problem you are describing.
>If so, please could you look into the circumstances that are causing
>the OOM killer to do this. Normally rpciod should never be much of a
>memory hog.


No, rpciod has never been killed by the OOM killer, afaict, the other 
processes OOM killer has killed have all been logged and rpciod has never 
been in that list. rpciod is always using a small amount of RAM.

Also, I can confirm that this problem has happened when the machine was 
fairly low on memory but not low enough to invoke the OOM killer. And as I 
noted before, access to other mounts - mounted from the same NFS server - 
on the client system is not interrupted when one of these hangs occur.

I realize part of the problem is I haven't been able to reliably identify 
exactly what is  causing the problem, but I was hoping someone with more 
knowledge of the client code or someone who had seen this problem before 
could point me in the right direction.


Thanks,
andrew


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
