From: Paul Heinlein <heinlein@cse.ogi.edu>
Subject: Re: Input/output error on hard mounted NFS directory
Date: Tue, 14 May 2002 06:32:08 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0205140618080.21683-100000@glenfiddich.cse.ogi.edu>
References: <Pine.LNX.4.30.0205141159580.28229-100000@elin.scali.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: NFS mailinglist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from cse.ogi.edu ([129.95.20.2] helo=church.cse.ogi.edu)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 177cPe-0001da-00
	for <nfs@lists.sourceforge.net>; Tue, 14 May 2002 06:32:22 -0700
To: Steffen Persvold <sp@scali.com>
In-Reply-To: <Pine.LNX.4.30.0205141159580.28229-100000@elin.scali.no>
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

On Tue, 14 May 2002, Steffen Persvold wrote:

> The relevant /proc/mounts looks like this :
> 
> huey:/export/home/sp /home/sp nfs rw,v3,rsize=8192,wsize=8192,intr,addr=huey 0 0

Pardon my asking a question that's likely irrelevant -- but why are 
your {r,w}size settings stuck at 8k? I've never done any transfer-size 
testing under a 2.2.x kernel, but won't it negotiate something closer 
to 32k when running nfs v3?

+----------------------------------------------+----------------------+
| Paul Heinlein                                | heinlein@cse.ogi.edu |
| Research Systems Engineer                    |      +1 503 748-1472 |
| Department of Computer Science & Engineering | 20000 NW Walker Road |
| OGI School of Science & Engineering          |  Beaverton, OR 97006 |
| Oregon Health & Science University           |                  USA |
+----------------------------------------------+----------------------+


_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
