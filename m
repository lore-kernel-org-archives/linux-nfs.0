From: Steve Fosdick <lists@pelvoux.nildram.co.uk>
Subject: Re: Re: [autofs] VFS: Busy inodes after unmount on 2 way SMP
Date: Mon, 29 Sep 2003 00:16:41 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030928231641.GA18085@pelvoux.gotadsl.co.uk>
References: <16243.34641.819894.763746@charged.uio.no> <200309261831.h8QIVNVw026806@buggy.badula.org> <16244.48596.850187.268449@charged.uio.no> <20030927165504.GB5316@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; Format=Flowed; DelSp=Yes; charset=ISO-8859-15
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A3lZA-0008Ec-00
	for <nfs@lists.sourceforge.net>; Sun, 28 Sep 2003 17:07:04 -0700
Received: from panoramix.vasoftware.com
	([198.186.202.147] helo=externalmx.vasoftware.com ident=mail)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A3lZ9-0006Rs-N4
	for nfs@lists.sourceforge.net; Sun, 28 Sep 2003 17:07:03 -0700
Received: from pelvoux.gotadsl.co.uk ([62.3.242.73]:37635)
	by externalmx.vasoftware.com with esmtp (Exim 4.22 #1 (Debian))
	id 1A3kni-0002L0-9F
	for <nfs@lists.sourceforge.net>; Sun, 28 Sep 2003 16:18:02 -0700
Received: from localhost
	([127.0.0.1] helo=pelvoux ident=fozzy)
	by pelvoux.gotadsl.co.uk with esmtp (Exim 3.36 #1 (Debian))
	id 1A3kmQ-0004hx-00
	for <nfs@lists.sourceforge.net>; Mon, 29 Sep 2003 00:16:42 +0100
To: nfs@lists.sourceforge.net
In-Reply-To: <20030927165504.GB5316@suse.de>; from okir@suse.de on Sat, Sep 27, 2003 at 17:55:04 +0100
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On 2003.09.27 17:55, Olaf Kirch wrote:

> In this case, not removing the sillyrenamed file instead
> of oopsing may be the preferred action.

Would it be possibly to combine both ideas, i.e. have the last process
wait, but if the user attempt to kill that process and it will be
allowed because intr is set the sillyrenamed file is not removed.

Surely it is reasonable for people who kill -9 things to expect to do
some tidying up, but not to expect a kernel panic.

Steve.


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
