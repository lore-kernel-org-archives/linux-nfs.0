From: Paul Clements <paul.clements@steeleye.com>
Subject: Re: file :"/var/lib/nfs/rmtab"
Date: Thu, 03 Feb 2005 11:04:46 -0500
Message-ID: <42024B9E.1010102@steeleye.com>
References: <20050203113820.811.qmail@web51601.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: James Pearson <james-p@moving-picture.com>,
	nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CwjUC-0006x3-Su
	for nfs@lists.sourceforge.net; Thu, 03 Feb 2005 08:05:40 -0800
Received: from stat16.steeleye.com ([209.192.50.48] helo=hancock.sc.steeleye.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CwjUB-0001IH-An
	for nfs@lists.sourceforge.net; Thu, 03 Feb 2005 08:05:40 -0800
To: mehta kiran <kiranmehta1981@yahoo.com>
In-Reply-To: <20050203113820.811.qmail@web51601.mail.yahoo.com>
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

mehta kiran wrote:

> Isn't handle supplied by client
>           enough to verify clients access to
>           filesystem.?

Yes, it should be. That's why in 2.6, the rmtab file is no longer relied 
upon. Instead, there is a special filesystem, /proc/fs/nfsd, that allows 
the kernel to communicate with mountd in order to authenticate 
unrecognized clients automatically.

--
Paul


-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
