From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH] locks: provide a file lease method
 enabling	cluster-coherent leases
Date: Fri, 01 Jun 2007 09:14:53 -0400
Message-ID: <46601BCD.8050609@redhat.com>
References: <1180647624483-git-send-email-bfields@fieldses.org>	<11806476252240-git-send-email-bfields@fieldses.org>
	<11806476252913-git-send-email-bfields@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	David Teigland <teigland@redhat.com>,
	Marc Eshel <eshel@almaden.ibm.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hu6yd-0004vE-EB
	for nfs@lists.sourceforge.net; Fri, 01 Jun 2007 06:15:35 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hu6yf-00029a-3I
	for nfs@lists.sourceforge.net; Fri, 01 Jun 2007 06:15:38 -0700
In-Reply-To: <11806476252913-git-send-email-bfields@fieldses.org>
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

J. Bruce Fields wrote:
> From: J. Bruce Fields <bfields@fieldses.org>
>
> Currently leases are only kept locally, so there's no way for a distributed
> filesystem to enforce them against multiple clients.  We're particularly
> interested in the case of nfsd exporting a cluster filesystem, in which
> case nfsd needs cluster-coherent leases in order to implement delegations
> correctly.

A couple of naive questions --

Do the semantics of these leases really match the requirements from NFSv4?
Does the internal NFSv4 server state also need to be shared?

    Thanx...

       ps

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
