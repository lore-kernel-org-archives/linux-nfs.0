From: "Aaron D. Ball" <adb@bdi.com>
Subject: Re: append-only attribute support
Date: Fri, 21 Jan 2005 13:12:40 -0500
Message-ID: <41F14618.70500@bdi.com>
References: <8381054C-6B13-11D9-BFA6-000D933B35AA@bdi.com>	 <1106318654.3200.38.camel@tribesman.namesys.com>	 <1106322787.30627.5.camel@lade.trondhjem.org>  <41F12C75.5040007@bdi.com>	 <1106327280.9849.32.camel@lade.trondhjem.org>  <41F1423F.3080800@bdi.com> <1106330559.9849.73.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cs3G6-0003cM-HU
	for nfs@lists.sourceforge.net; Fri, 21 Jan 2005 10:11:46 -0800
Received: from shinjuku.bdi.com ([63.124.198.36])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.41)
	id 1Cs3G5-0000Dr-4T
	for nfs@lists.sourceforge.net; Fri, 21 Jan 2005 10:11:46 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1106330559.9849.73.camel@lade.trondhjem.org>
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

Trond Myklebust wrote:

> Don't you mean
>
>	if ((IS_APPEND(inode) && (access & MAY_WRITE)) || IS_ISMNDLK(inode))
>
>;-)
>  
>
Yep, I retyped it without my brain engaged.  Guess 1 PM is past my bedtime.

It'll be a few hours before I can try this out.  Does anything else 
suggest itself in the mean time?


-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
