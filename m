From: Andrea Righi <righiandr@users.sourceforge.net>
Subject: Re: nfsd closes port 2049
Date: Mon, 15 Oct 2007 21:34:59 +0200 (MEST)
Message-ID: <4713C0E4.4040300@users.sourceforge.net>
References: <47139C02.9020009@cineca.it>
	<EXNANE01sVxONvzyJxA000006ff@exnane01.hq.netapp.com>
	<4713B033.6040207@users.sourceforge.net>
	<EXNANE01IcVux1Zcn8T00000700@exnane01.hq.netapp.com>
Reply-To: righiandr@users.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IhVpz-0005ZD-At
	for nfs@lists.sourceforge.net; Mon, 15 Oct 2007 12:43:27 -0700
Received: from as3.cineca.com ([130.186.84.211])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IhVq3-0005zE-6a
	for nfs@lists.sourceforge.net; Mon, 15 Oct 2007 12:42:56 -0700
In-Reply-To: <EXNANE01IcVux1Zcn8T00000700@exnane01.hq.netapp.com>
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

Talpey, Thomas wrote:
> I'm snipping out LKMLfrom the cc, this isn't really a kernel issue.
> 
> I can give two suggestions. One, look carefully at whether GPFS had
> a momentary issue at the time of any error. The server permission check
> would consult it, and any error will cause the export to be denied.
> 
> Second, you can add "no_subtree_check" to the export line, which
> will bypass this checking. Since you appear to be exporting the root
> of the filesystem, it seems there is little need for this checking. In
> newer versions of nfs_utils, non-checking is in fact the default. You
> can read about the option with "man exports".

No error logged by GPFS during the latest failure. But I'll try the
no_subtree_check and I'll keep you informed.

Thanks,
-Andrea

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
