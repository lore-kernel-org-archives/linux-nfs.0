From: Martin Pool <mbp@sourcefrog.net>
Subject: Re: cat /proc/fs/nfs/exports hangs
Date: Thu, 4 Sep 2003 12:46:31 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030904124631.6ddb1fee.mbp@sourcefrog.net>
References: <3F54E248.30102@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19uk9C-0006sl-00
	for <nfs@lists.sourceforge.net>; Wed, 03 Sep 2003 19:46:58 -0700
Received: from sngrel7.hp.com ([192.6.86.111])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19uk99-0000rD-Ur
	for nfs@lists.sourceforge.net; Wed, 03 Sep 2003 19:46:56 -0700
Received: from XAUBRG2.AUS.HP.COM (xaubrg2.aus.hp.com [15.23.69.43])
	by sngrel7.hp.com (Postfix) with SMTP id 55C04AC5
	for <nfs@lists.sourceforge.net>; Thu,  4 Sep 2003 10:46:50 +0800 (SGP)
To: r.ems@gmx.net
In-Reply-To: <3F54E248.30102@gmx.net>
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

On  2 Sep 2003 Richard Ems <r.ems@gmx.net> wrote:

> Hi all!
> 
> This is a dual Athlon system with SuSE 8.2.
> Kernel is SuSE's k_smp-2.4.21-4.
> 
> After 32 days of uptime nfs exports stopped working.
> While trying to restart the nfs server them I found that running 
> "rcnfsserver restart" hangs on exportfs (process ind D state)
> 
> Also a simple "cat /proc/fs/nfs/exports" hangs (process in D state).
> 
> The last lines from "strace cat /proc/fs/nfs/exports" show:
> 
> munmap(0x40016000, 59621)               = 0
> open("/usr/lib/locale/locale-archive", O_RDONLY|O_LARGEFILE) = 3
> fstat64(3, {st_mode=S_IFREG|0644, st_size=32058672, ...}) = 0
> mmap2(NULL, 2097152, PROT_READ, MAP_PRIVATE, 3, 0) = 0x40158000
> close(3)                                = 0
> brk(0)                                  = 0x804c68c
> brk(0x804d68c)                          = 0x804d68c
> brk(0)                                  = 0x804d68c
> brk(0x804e000)                          = 0x804e000
> fstat64(1, {st_mode=S_IFCHR|0620, st_rdev=makedev(136, 2), ...}) = 0
> open("/proc/fs/nfs/exports", O_RDONLY|O_LARGEFILE) = 3
> fstat64(3, {st_mode=S_IFREG|0444, st_size=0, ...}) = 0
> read(3,  <unfinished ...>

I don't know the answer, but you can get some more potentially
interesting information by looking at the wait channel of cat and of
other relevant processes.

  # ps axo pid,cmd,wchan

-- 
Martin 


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
