From: Jos van Wezel <jvw@iwr.fzk.de>
Subject: Re: rpc.mountd: getfh failed: Operation not permitted
Date: Thu, 03 Feb 2005 18:52:32 +0100
Message-ID: <420264E0.4080107@iwr.fzk.de>
References: <20050203041550.746BD89D13@sc8-sf-spam1.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cwl9y-000404-B3
	for nfs@lists.sourceforge.net; Thu, 03 Feb 2005 09:52:54 -0800
Received: from fzkmail2.fzk.de ([141.52.27.52])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.41)
	id 1Cwl9v-0007CW-V4
	for nfs@lists.sourceforge.net; Thu, 03 Feb 2005 09:52:54 -0800
To: nfs@lists.sourceforge.net,
	"jehan.procaccia" <jehan.procaccia@int-evry.fr>,
	Steve Dickson <SteveD@redhat.com>
In-Reply-To: <20050203041550.746BD89D13@sc8-sf-spam1.sourceforge.net>
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

Sorry Steve, your suggestion does not help, at least in our case. All 
mounts via
tcp on nfs server with RH ES3, 2.4.21-15. It is a very annoying issue.

J

> Date: Wed, 02 Feb 2005 09:02:30 -0500
> From: Steve Dickson <SteveD@redhat.com>
> To: "jehan.procaccia" <jehan.procaccia@int-evry.fr>
> CC: nfs@lists.sourceforge.net
> Subject: Re: [NFS] rpc.mountd: getfh failed: Operation not permitted
> 
> 
> 
> jehan.procaccia wrote:
> 
> 
>>Can someone give me a clue about this "getfh" error ?
> 
> 
> Try exporting the filesystem with the 'no_subtree_check'
> option set to see if that helps....
> 
> steved.
> 
> 


-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
