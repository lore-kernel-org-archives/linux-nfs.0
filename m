From: Steve Dickson <SteveD@redhat.com>
Subject: Re: lockd grace period
Date: Mon, 31 Jan 2005 10:01:59 -0500
Message-ID: <41FE4867.4070709@RedHat.com>
References: <20050131143610.1250.qmail@web51604.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: "Aswathanarayana, Chetan (STSD)" <chetan.aswathanarayana@hp.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cvd1q-0001vy-2d
	for nfs@lists.sourceforge.net; Mon, 31 Jan 2005 06:59:50 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1Cvd1p-0002lz-Hl
	for nfs@lists.sourceforge.net; Mon, 31 Jan 2005 06:59:50 -0800
To: mehta kiran <kiranmehta1981@yahoo.com>
In-Reply-To: <20050131143610.1250.qmail@web51604.mail.yahoo.com>
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

>Hi , 
>          this means that if  lockd alone is running
>since a long time and if now i start nfsd , 
>
hmm... why would you ever have lockd running "alone"?
Meaning what good is it w/out rpc.nfsd? Also how are
you doing that since one of the first things rpc.nfsd does
is bring up lockd().....

steved.



-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
