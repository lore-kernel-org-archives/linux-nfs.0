From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH] NFS nolock broken in 2.6.9-rc4
Date: Fri, 15 Oct 2004 17:12:57 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20041015151257.GF27307@suse.de>
References: <20041015095840.GA22992@suse.de> <1097851471.5558.12.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, Andrew Morton <akpm@osdl.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CITxn-0005l6-Ik
	for nfs@lists.sourceforge.net; Fri, 15 Oct 2004 08:25:51 -0700
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1CITxk-0001CL-Qh
	for nfs@lists.sourceforge.net; Fri, 15 Oct 2004 08:25:51 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1097851471.5558.12.camel@lade.trondhjem.org>
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

On Fri, Oct 15, 2004 at 04:44:31PM +0200, Trond Myklebust wrote:
> NO! The correct way to do this is to handle it with a call to
> posix_lock_file() in the NFS code for the particular case of "nolock".

Urrrgh.. this looks complicated and duplicates code. Then I'd rather
have two struct file_operations, one for normal operations with a .lock
function, and a second one for nolock without.

> for details on why the changes were made (and that should make it
> obvious why your patch is wrong). The VFS must NOT be allowed to
> interfere if a filesystem has its own ->lock() method: that will violate
> the ability of filesystems to impose rigid locking rules.

My patch doesn't interfere; it just falls back to the original code if
the fs routine returns LOCK_USE_CLNT. In that respect, it doesn't
interfere with the new code.

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
