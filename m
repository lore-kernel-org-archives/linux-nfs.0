From: Olaf Hering <olh@suse.de>
Subject: Re: 2.6.0-test10, oops in nfs_kill_super
Date: Thu, 27 Nov 2003 18:02:04 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20031127170204.GA14765@suse.de>
References: <20031127162511.GA15901@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linuxppc64-dev@lists.linuxppc.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1APPWp-0004WI-00
	for <nfs@lists.sourceforge.net>; Thu, 27 Nov 2003 09:02:07 -0800
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.24)
	id 1APPWo-0007md-Og
	for nfs@lists.sourceforge.net; Thu, 27 Nov 2003 09:02:07 -0800
To: nfs@lists.sourceforge.net
In-Reply-To: <20031127162511.GA15901@suse.de>
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

 On Thu, Nov 27, Olaf Hering wrote:

> It dies in invalidate_list()
>                 next = next->next;
> 
> However, why does r3 and r27 differ even if they should be the same?

Scratch that, its a loop...

-- 
USB is for mice, FireWire is for men!

sUse lINUX ag, nÜRNBERG


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
