From: Frank van Maarseveen <frankvm@xs4all.nl>
Subject: Re: permission bits for group not honoured on directory creation
Date: Thu, 2 Sep 2004 23:00:05 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040902210005.GB4801@janus>
References: <E1C1GJx-00018A-2R@sc8-sf-list2.sourceforge.net> <Pine.LNX.4.44.0409022203580.17829-100000@hikjos.fzk.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C2ygi-0001sl-PA
	for nfs@lists.sourceforge.net; Thu, 02 Sep 2004 14:00:08 -0700
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1C2ygh-0005B3-B4
	for nfs@lists.sourceforge.net; Thu, 02 Sep 2004 14:00:08 -0700
To: Jos van Wezel <jvw@iwr.fzk.de>
In-Reply-To: <Pine.LNX.4.44.0409022203580.17829-100000@hikjos.fzk.de>
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

On Thu, Sep 02, 2004 at 10:08:54PM +0200, Jos van Wezel wrote:
> Dear all,
> 
> on an nfs v3 mounted file system (linux client and server):
> 
> # umask
> 0002
> # mkdir d
> # ls -ld d
> drwxr-xr-x    2 root     root         8192 Sep  2  2004 d/
> #

cannot reproduce. I would surely be bitten by such a bug.

kernel versions ?
client: how do the relevant /proc/mounts entries look?
server: relevant /etc/exports lines?

-- 
Frank


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
