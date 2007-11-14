From: Jeff Layton <jlayton@redhat.com>
Subject: Re: Oops in rpciod when building procmail from an NFS client
Date: Wed, 14 Nov 2007 03:59:55 -0500
Message-ID: <20071114035955.35517bb9@tleilax.poochiereds.net>
References: <83FE585A3944624683D9A3F69BA108EB0224B633@PUN2K3EXCL01.symphonysv.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Yogesh Pahilwan" <Yogesh.Pahilwan@symphonysv.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IsE6O-0008Ne-A5
	for nfs@lists.sourceforge.net; Wed, 14 Nov 2007 01:00:04 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IsE6T-0006X8-15
	for nfs@lists.sourceforge.net; Wed, 14 Nov 2007 01:00:10 -0800
In-Reply-To: <83FE585A3944624683D9A3F69BA108EB0224B633@PUN2K3EXCL01.symphonysv.com>
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

On Wed, 14 Nov 2007 11:59:15 +0530
"Yogesh Pahilwan" <Yogesh.Pahilwan@symphonysv.com> wrote:

> NFS client configuration: kernel version - 2.6.11-1.1369_FC4

The oops you posted doesn't look familiar to me, but this kernel is
truly ancient. Fedora Core 4 is well past its end of life. I'd suggest
updating to Fedora 7 or 8 and seeing if your problem is still
reproducible.

-- 
Jeff Layton <jlayton@redhat.com>

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
