From: Steve Dickson <SteveD@redhat.com>
Subject: Re: lockd grace period
Date: Mon, 31 Jan 2005 09:58:30 -0500
Message-ID: <41FE4796.9060909@RedHat.com>
References: <395A443A7CBF0246843BFD3471A8231DC0176D@bgeexc04.asiapacific.cpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: mehta kiran <kiranmehta1981@yahoo.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cvcya-0001du-6A
	for nfs@lists.sourceforge.net; Mon, 31 Jan 2005 06:56:28 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CvcyZ-0000mV-Iz
	for nfs@lists.sourceforge.net; Mon, 31 Jan 2005 06:56:28 -0800
To: "Aswathanarayana, Chetan (STSD)" <chetan.aswathanarayana@hp.com>
In-Reply-To: <395A443A7CBF0246843BFD3471A8231DC0176D@bgeexc04.asiapacific.cpqcorp.net>
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

Aswathanarayana, Chetan (STSD) wrote:

>Say, a reclaim request arrives after grace period and get's lock. There
>will be time frame between end of grace period and arrival of
>Reclaim request, in which case any thing can happen(ex: a new request
>could be granted, it may make some changes to a file and unlock by the
>time Reclaim arrives).
>  
>
Nobody  is saying this NLM protocol or method of recovery is perfect.... 
;-)  This
is one of many reasons why the locking protocol is not integrated with the
NFSv4 protocol...

steved.



-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
