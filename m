From: Steve Dickson <SteveD@redhat.com>
Subject: Re: lockd grace period
Date: Mon, 31 Jan 2005 11:01:05 -0500
Message-ID: <41FE5641.2060707@RedHat.com>
References: <20050131150955.81041.qmail@web51610.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: "Aswathanarayana, Chetan (STSD)" <chetan.aswathanarayana@hp.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CvdxP-0005Hq-7j
	for nfs@lists.sourceforge.net; Mon, 31 Jan 2005 07:59:19 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CvdxN-0003PA-Jg
	for nfs@lists.sourceforge.net; Mon, 31 Jan 2005 07:59:19 -0800
To: mehta kiran <kiranmehta1981@yahoo.com>
In-Reply-To: <20050131150955.81041.qmail@web51610.mail.yahoo.com>
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
>     lockd can run alone if this machine also acts
>as nfs client of some other (third machine)
>Clients side only require lockd and rpciod , right 
>  
>
hmm... I always think of lockd being a server only process...
but indeed it is started for callbacks and reclaims on the client side so
so point taken... I guess what threw me was the idea of lockd
running "alone".... lockd never runs along (i.e. w/out
some type of NFS activity)....

So your question is, when there is already an active NFS mount
(which would bring up lockd()) and then NFS server is started
will lockd() have a grace period. From what I see the answer
is no. Probably because the its expected that the server will
be started before any NFS would occur which does occur
99% of the time....

steved.



-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
