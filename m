From: Sverker Wiberg <Sverker.Wiberg@uab.ericsson.se>
Subject: Re: PROBLEM: knfsd misses occasional writes (w/ WORKAROUND)
Date: Fri, 17 May 2002 14:32:36 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <ac39uu$pv$2@main.gmane.org>
References: <3CE250A5.47F71DF@uab.ericsson.se> <15586.20989.992591.474108@notabene.cse.unsw.edu.au> <3CE38E9D.986ACF7F@uab.ericsson.se> <20020516143441.A4322@laclinux.com> <3CE4DD8C.69C34A1B@uab.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from to-velocet.redhat.com ([216.138.202.10] helo=touchme.toronto.redhat.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 178kGm-00084q-00
	for <nfs@lists.sourceforge.net>; Fri, 17 May 2002 09:07:52 -0700
Received: from toomuch.toronto.redhat.com (unknown [172.16.14.22])
	by touchme.toronto.redhat.com (Postfix) with ESMTP id DA472B8036
	for <nfs@lists.sourceforge.net>; Fri, 17 May 2002 12:07:47 -0400 (EDT)
Received: (from bcrl@localhost)
	by toomuch.toronto.redhat.com (8.11.6/8.11.2) id g4HG7l116663
	for nfs@lists.sourceforge.net; Fri, 17 May 2002 12:07:47 -0400
Resent-Message-Id: <200205171607.g4HG7l116663@toomuch.toronto.redhat.com>
To: linux-kernel@vger.kernel.org
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

Sverker Wiberg wrote:

> Over here, we started to log the conversations, and saw the client
> opening a file, writing 272 bytes into it (one write), and then closing
> it, with the server replying full success all the time. printk()'s in
> knfsd and the vfs's generic_write() also reported that 272 bytes had
> been successfully written. Yet the file was truncated.
> 
> We switched from soft to hard mount: It didn't help. We are now
> experimenting with disabling SCSI's disconnect/reconnect feature. Are
> there any more straws to grasp at?

With one single knfsd thread running, the problem went away (for a price
in performance). This seems to indicate there is some kind of race
between the knfsd threads. 

/Sverker
-
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/

_______________________________________________________________

Hundreds of nodes, one monster rendering program.
Now that’s a super model! Visit http://clustering.foundries.sf.net/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
