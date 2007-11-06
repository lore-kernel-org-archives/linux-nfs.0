From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [PATCH 00/15] Rewrite nfs(5) man page
Date: Tue, 06 Nov 2007 16:56:08 -0500
Message-ID: <EXNANE01xJagXTi8M19000008c3@exnane01.hq.netapp.com>
References: <20071106005731.5037.57716.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IpWPw-0004Bj-Vj
	for nfs@lists.sourceforge.net; Tue, 06 Nov 2007 13:57:05 -0800
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IpWQ2-0008JR-IA
	for nfs@lists.sourceforge.net; Tue, 06 Nov 2007 13:57:10 -0800
In-Reply-To: <20071106005731.5037.57716.stgit@ellison.1015granger.net>
References: <20071106005731.5037.57716.stgit@ellison.1015granger.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Do you by any chance have a formatted rollup of these changes on
the web somewhere? Yes, I can merge them myself and view the
result but... :-)

Tom.

At 08:02 PM 11/5/2007, Chuck Lever wrote:
>As I was working on the new text-based mount.nfs command, I noticed a number
>of inaccuracies in the nfs(5) man page.  I decided to update the section that
>describes mount options to reflect what I believe to be implemented in the
>current legacy mount.nfs ABI and in the new text-based implementation.
>
>It also seemed prudent to provide some sections giving background about how
>the mount options are used, and how the NFS client works in general.
>
>This all ended up being a rather significant rewrite of nfs(5).
>
>At this point I think we're ready for further review, and then to tuck it
>into nfs-utils and have other people hack at it a bit more before the next
>nfs-utils release.
>
>-------------------------------------------------------------------------
>This SF.net email is sponsored by: Splunk Inc.
>Still grepping through log files to find problems?  Stop.
>Now Search log events and configuration files using AJAX and a browser.
>Download your FREE copy of Splunk now >> http://get.splunk.com/
>_______________________________________________
>NFS maillist  -  NFS@lists.sourceforge.net
>https://lists.sourceforge.net/lists/listinfo/nfs

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
