From: Scott McDermott <mcdermot@questra.com>
Subject: Re: a NFS problem
Date: Thu, 10 Oct 2002 13:54:19 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021010135419.W5483@questra.com>
References: <200210092038.QAA47299@protein3d.ncifcrf.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ns1.questra.com ([64.132.48.186] helo=questra.com)
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17zhVv-0001KU-00
	for <nfs@lists.sourceforge.net>; Thu, 10 Oct 2002 10:54:23 -0700
Received: (from mcdermot@localhost)
	by odio.roc.questra.com (8.11.6/8.11.4) id g9AHsJr13607
	for nfs@lists.sourceforge.net; Thu, 10 Oct 2002 13:54:19 -0400
To: nfs@lists.sourceforge.net
In-Reply-To: <200210092038.QAA47299@protein3d.ncifcrf.gov>; from tsai@protein3d.ncifcrf.gov on Wed, Oct 09, 2002 at 04:38:41PM -0400
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

Chung-Jung Tsai on Wed  9/10 16:38 -0400:
> Files written by a f90 program running at master node were not updated
> for the other nodes to see their content correctly. It seems like a
> sync problem.

I believe the sync consistency threshold is one second.  Subsecond
coherency cannot be acheived, IIRC.  Check the list archives for more
information.


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
