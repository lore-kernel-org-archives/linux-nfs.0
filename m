From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: NFSv3 lockd performance problem
Date: Fri, 4 Feb 2005 16:24:57 +1100
Message-ID: <16899.1833.49838.905916@cse.unsw.edu.au>
References: <482A3FA0050D21419C269D13989C6113085396DE@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cwvxs-0000EE-Pt
	for nfs@lists.sourceforge.net; Thu, 03 Feb 2005 21:25:08 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Cwvxr-0007hL-AU
	for nfs@lists.sourceforge.net; Thu, 03 Feb 2005 21:25:08 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: message from Lever, Charles on Thursday February 3
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Thursday February 3, Charles.Lever@netapp.com wrote:
> hi neil-
> 
> when i run the connectathon locking tests over NFSv3 from a Linux
> client, the suite bogs down during test #7 and #12 because of problems
> authenticating the lockd callbacks.  bruce fields pointed me to some
> patches that he's already forwarded to you, which fix the problem for
> me.  they are patches 02 through 08 on this web page:
> 
> http://www.citi.umich.edu/projects/nfsv4/linux/kernel-patches/2.6.11-rc2
> -1/
> 
> i was wondering if we can get these in 2.6.11?  while the problem
> doesn't appear to affect correctness, the performance impact is
> significant, enough that might affect any real world workloads that
> depend on NLM locking.

Hopefully, yes.  I've got quite a backlog of issues due to a few weeks
leave that I have recently returned from.  Bruce's patches should be
on their way to Andrew in a few days.

NeilBrown


-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
