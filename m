From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFS Server problem (kernel > 2.6.5 ?)
Date: Wed, 27 Oct 2004 12:50:17 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20041027165017.GE4292@fieldses.org>
References: <001801c4bb3d$5d670bd0$1203a8c0@utvikling> <417E8DFA.5090204@psu.edu> <001501c4bc44$051867a0$1203a8c0@utvikling>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, Jason Holmes <jholmes@psu.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CMr00-0006mQ-Rt
	for nfs@lists.sourceforge.net; Wed, 27 Oct 2004 09:50:12 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.41)
	id 1CMqzz-0002xA-Ug
	for nfs@lists.sourceforge.net; Wed, 27 Oct 2004 09:50:12 -0700
To: mrg <mrg@normailer.com>
In-Reply-To: <001501c4bc44$051867a0$1203a8c0@utvikling>
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

On Wed, Oct 27, 2004 at 06:43:00PM +0200, mrg wrote:
> Thanks, it worked!
> 
> I uninstalled the nfs-utils-1.0.6-22 (from FC2), then installed
> nfs-utils-1.0.6 from kernel.org. Et voila!

If you download the FC2 srpm you can see the list of patches that
distinguishes their version from stock nfs-utils-1.0.6.  It might be
useful to figure out exactly which of those patches it is that causes
the problem.

--b.


-------------------------------------------------------
This SF.Net email is sponsored by:
Sybase ASE Linux Express Edition - download now for FREE
LinuxWorld Reader's Choice Award Winner for best database on Linux.
http://ads.osdn.com/?ad_id=5588&alloc_id=12065&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
