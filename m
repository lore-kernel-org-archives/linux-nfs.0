From: Steve Dickson <SteveD@redhat.com>
Subject: Re: lockd grace period
Date: Mon, 31 Jan 2005 07:33:15 -0500
Message-ID: <41FE258B.2000803@RedHat.com>
References: <20050131074127.32205.qmail@web51603.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cvaht-0002hB-Hg
	for nfs@lists.sourceforge.net; Mon, 31 Jan 2005 04:31:05 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1Cvahr-00068g-JV
	for nfs@lists.sourceforge.net; Mon, 31 Jan 2005 04:31:05 -0800
To: mehta kiran <kiranmehta1981@yahoo.com>
In-Reply-To: <20050131074127.32205.qmail@web51603.mail.yahoo.com>
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

>What is the expected behaviour.?
>Is it that whenever nfsd starts  , lockd should enter
>grace period ?
>or
>Is is that lockd should enter grace period only when
>it restarts without caring for nfs.?
>  
>
Yes and Yes... When a NFS server is restarted, there is a grace
period in which the server (i.e. lockd) will accept reclaimed locks.
And it appears that reclaimed locks will also be accepted after
the grace period expires so its not clear who and how that
error is being generated....

steved.


-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
