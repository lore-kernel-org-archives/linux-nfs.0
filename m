From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Failure to mount from multiple servers in a short period
 of time
Date: Mon, 31 Jan 2005 07:16:55 -0500
Message-ID: <41FE21B7.7020309@RedHat.com>
References: <200501310424.j0V4OF5e000412@m27.ligo.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CvaSC-0001nv-4N
	for nfs@lists.sourceforge.net; Mon, 31 Jan 2005 04:14:52 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CvaSA-000454-N2
	for nfs@lists.sourceforge.net; Mon, 31 Jan 2005 04:14:52 -0800
To: Stuart Anderson <anderson@ligo.caltech.edu>
In-Reply-To: <200501310424.j0V4OF5e000412@m27.ligo.caltech.edu>
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

Stuart Anderson wrote:

>On a dual-Xeon 4GB server running FC3 I am unable to successfully
>issue more than 52 automount requests to unique Linux NFS servers
>in less than a minute.
>  
>
Yes is this is a know problem that we run out of reserve ports due to the
fact so many are used up during TCP mounts.... We are looking into
this issue.... and hope to a resolution soon.... its Bugzilla 141773 for
those who are interested....

steved.



-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
