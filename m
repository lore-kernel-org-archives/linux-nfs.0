From: Olaf Kirch <okir@suse.de>
Subject: Re: ps -aux hangs on [nfsd]
Date: Fri, 28 Jan 2005 11:22:23 +0100
Message-ID: <20050128102223.GB32084@suse.de>
References: <41DE6CF9.6030100@bio.ifi.lmu.de> <41F8C900.90404@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS NFS <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CuTGo-0006Zr-3M
	for nfs@lists.sourceforge.net; Fri, 28 Jan 2005 02:22:30 -0800
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1CuTGm-0005EA-IR
	for nfs@lists.sourceforge.net; Fri, 28 Jan 2005 02:22:30 -0800
To: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
In-Reply-To: <41F8C900.90404@bio.ifi.lmu.de>
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

On Thu, Jan 27, 2005 at 11:57:04AM +0100, Frank Steiner wrote:
> Here are the relevant portions of the strace log, maybe someone
> has an idea what could go wrong here.

This doesn't look like an NFS bug; it's a problem in procps or glibc.

When you do a ps aux, ps ends up in a function named simple_readtask
(in procps/proc/readproc.c) which does this:

	stat /proc/<pid>
	read /proc/<pid>/stat
	read /proc/<pid>/status
	map the uids it found to login names

The latter happens via a function named user_from_uid(), which caches
these mappings - this is the reason why you're not seeing an access to
/etc/passwd on every call.

But it doesn't look like user_from_uid() could loop at all. So
possibly somethings wrong inside glibc (unlikely as that is).

Olaf
-- 
Olaf Kirch     | Things that make Monday morning interesting, #2:
okir@suse.de   |        "We have 8,000 NFS mount points, why do we keep
---------------+ 	 running out of privileged ports?"


-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
