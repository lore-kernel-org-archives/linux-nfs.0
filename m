From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: Re: mount.nfs: chk_mountpoint()
Date: Thu, 30 Aug 2007 12:12:49 +0200
Message-ID: <20070830101249.GA9880@janus>
References: <46CC884B.1030207@oracle.com> <46CD82A0.1000408@redhat.com>
	<46CDC7D0.6030803@oracle.com> <46CDD069.3070608@redhat.com>
	<46CDE76C.3040800@oracle.com> <46CDEA2E.10902@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Peter Staubach <staubach@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQh18-00058D-4A
	for nfs@lists.sourceforge.net; Thu, 30 Aug 2007 03:13:08 -0700
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IQh1B-0000jP-14
	for nfs@lists.sourceforge.net; Thu, 30 Aug 2007 03:12:54 -0700
In-Reply-To: <46CDEA2E.10902@redhat.com>
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

On Thu, Aug 23, 2007 at 04:12:30PM -0400, Peter Staubach wrote:
> 
> I would guess that not so many people are using the "bg" option,
> period.  Many of Linux's customers are ex-Sun customers and they
> were educated to use autofs and to move away from and stay away
> from static mounts via fstab or vfstab.
> 
> The "bg" option was a hack added to speed up system booting.

No, it is indispensable to recover properly from a power outage:
servers tend to boot slower than clients. Also, it is not unusual to
have some minor network/server problems after an outage causing the
mount to fail.

Without the bg option a temporary power outage may render all client
systems unusable.

-- 
Frank

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
