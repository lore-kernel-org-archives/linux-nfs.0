From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFS Server problem (kernel > 2.6.5 ?)
Date: Tue, 26 Oct 2004 13:54:36 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20041026175436.GA26861@fieldses.org>
References: <001801c4bb3d$5d670bd0$1203a8c0@utvikling> <417E8DFA.5090204@psu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mrg <mrg@normailer.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CMVWl-0005in-6J
	for nfs@lists.sourceforge.net; Tue, 26 Oct 2004 10:54:35 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.41)
	id 1CMVWj-00020d-NR
	for nfs@lists.sourceforge.net; Tue, 26 Oct 2004 10:54:35 -0700
To: Jason Holmes <jholmes@psu.edu>
In-Reply-To: <417E8DFA.5090204@psu.edu>
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

On Tue, Oct 26, 2004 at 01:48:42PM -0400, Jason Holmes wrote:
> I had a similar problem when replacing the RedHat kernel on Enterprise 3 
> Update 3.  The problem was that the RedHat nfs-utils package didn't work 
> properly with the vanilla kernels (even though it's version 1.0.6, it's 
> a very much patched version of 1.0.6).  After replacing the nfs-utils 
> package with a vanilla 1.0.6, things worked fine.

That doesn't really explain what the problem was.  Would it be possible
to narrow down which patch exactly from the redhat rpm caused the
problem?

--Bruce Fields


-------------------------------------------------------
This SF.Net email is sponsored by:
Sybase ASE Linux Express Edition - download now for FREE
LinuxWorld Reader's Choice Award Winner for best database on Linux.
http://ads.osdn.com/?ad_id=5588&alloc_id=12065&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
