From: Ion Badulescu <ionut@badula.org>
Subject: Re: Re: broken umount -f
Date: Thu, 16 Jan 2003 15:49:27 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200301162049.h0GKnRr09341@buggy.badula.org>
References: <6440EA1A6AA1D5118C6900902745938E07D551FA@black.eng.netapp.com>
Cc: nfs@lists.sourceforge.net, Scott Mcdermott <smcdermott@questra.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ool-4351594a.dyn.optonline.net ([67.81.89.74] helo=buggy.badula.org)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18ZGxU-0001gf-00
	for <nfs@lists.sourceforge.net>; Thu, 16 Jan 2003 12:49:52 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <6440EA1A6AA1D5118C6900902745938E07D551FA@black.eng.netapp.com>
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

On Wed, 15 Jan 2003 09:04:58 -0800, Lever, Charles <Charles.Lever@netapp.com> wrote:
> 
> do you know what the risk of data corruption is when using "intr"?
> seems pretty low to me.

What is the risk, anyway? That the user will press Ctrl-C (SIGINT) and 
kill the process? How is that different from doing the same thing when
NFS is not hung? Sure, you can envision a case where the process traps
SIGINT so it is not fatal, yet the NFS request ends up being canceled, 
but it's hardly the end of the world.

I also think we have a misunderstanding here. SIGKILL should _always_ be able
to kill a process hanging on NFS. Unconditionally. It may not do it right
away, it may take a few seconds until the client exists the noninterruptible
sequence, but it should succeed eventually. The role of 'umount -f' then
becomes mostly to speed up the effects of the SIGKILL.

SIGINT should be able to do the same thing if the mount is done with 'intr'.
Nothing more and nothing less.

>From the Solaris mount_nfs(1M) man page:

           intr | nointr
                 Allow (do not allow) keyboard interrupts to kill
                 a process that  is  hung  while  waiting  for  a
                 response  on  a  hard-mounted  file system.  The
                 default is intr, which  makes  it  possible  for
                 clients  to  interrupt  applications that may be
                 waiting for a remote mount.

Linux does the above, mostly. The biggest problem is that sometimes
the hanging NFS access will be done by rpciod, not by the process
itself, and so it's rpciod that needs the SIGKILL (or SIGINT) in
order to abort the access. Unfortunately, rpciod is owned by root,
so a regular user can't send it any signals. For the sysadmin,
killall -KILL rpciod combined with umount -f does the trick most of
the time.

The other problem I've seen occasionally is that umount -f hangs
(interruptibly) instead of aborting all outstanding I/O's. I haven't
been able to find a pattern as to when it happens, yet.

Ion

-- 
  It is better to keep your mouth shut and be thought a fool,
            than to open it and remove all doubt.


-------------------------------------------------------
This SF.NET email is sponsored by: Thawte.com
Understand how to protect your customers personal information by implementing
SSL on your Apache Web Server. Click here to get our FREE Thawte Apache 
Guide: http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0029en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
