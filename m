From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH] NFS nolock broken in 2.6.9-rc4
Date: Mon, 18 Oct 2004 09:39:03 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20041018073903.GB24684@suse.de>
References: <20041015095840.GA22992@suse.de> <20041015100703.GA27307@suse.de> <20041016004957.38ccd273.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CJS6m-0000aQ-1E
	for nfs@lists.sourceforge.net; Mon, 18 Oct 2004 00:39:08 -0700
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1CJS6l-0006y6-I4
	for nfs@lists.sourceforge.net; Mon, 18 Oct 2004 00:39:07 -0700
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20041016004957.38ccd273.akpm@osdl.org>
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

On Sat, Oct 16, 2004 at 12:49:57AM -0700, Andrew Morton wrote:
> Did we come to a decision as to which patch to use?
> 
> When we do, someone please send me the patch.

Trond's the one with the maintainer hat.

I like a separate file_operations_nolock better since it's KISS, but
if he prefers the long and winding road of locks.c calling NFS calling
locks.c, I'm fine with that, too.

Olaf
-- 
Olaf Kirch     | Things that make Monday morning interesting, #1:
okir@suse.de   |        "I want to use NFS over AX25, can you help me?"
---------------+ 


-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
