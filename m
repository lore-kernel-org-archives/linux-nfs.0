From: Andrew Morton <akpm@osdl.org>
Subject: Re: Re: [PATCH] kNFSd - 2 of 5 - ip_map_init does a kmalloc
 which isn't checked...
Date: Mon, 9 Feb 2004 09:32:06 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040209093206.429ffb7e.akpm@osdl.org>
References: <20040206161050.27799.patches@notabene>
	<E1AoyIo-0007FS-00@notabene>
	<20040207012423.396efe73.akpm@osdl.org>
	<20040208043723.GC13391@fieldses.org>
	<20040207214637.387d3018.akpm@osdl.org>
	<20040208055921.GA14053@fieldses.org>
	<20040208203018.GA27482@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: neilb@cse.unsw.edu.au, nfs@lists.sourceforge.net,
	Philippe =?ISO-8859-1?B?R3JhbW91bGzp?= <philippe.gramoulle@mmania.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-list1-b.sourceforge.net ([10.3.1.7] helo=sc8-sf-list1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AqMgK-0000ww-Eh
	for nfs@lists.sourceforge.net; Mon, 09 Feb 2004 17:27:20 -0800
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 4.30)
	id 1AqFE6-00077e-Mk
	for nfs@lists.sourceforge.net; Mon, 09 Feb 2004 09:29:42 -0800
Received: from fw.osdl.org ([65.172.181.6] helo=mail.osdl.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1AqFE5-0006Xg-SZ
	for nfs@lists.sourceforge.net; Mon, 09 Feb 2004 09:29:42 -0800
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20040208203018.GA27482@fieldses.org>
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

Thanks, Philippe.

Bruce, 2.6.3-rc1-mm1 contains your later batch of patches (02 and 03 are
still in the wrong order, but that doesn't matter and I have subsequently
fixed that).

Begin forwarded message:

Date: Mon, 9 Feb 2004 15:18:18 +0100
From: Philippe Gramoull=E9 <philippe.gramoulle@mmania.com>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: 2.6.3-rc1-mm1



Hello Andrew,

On Mon, 9 Feb 2004 01:40:35 -0800
Andrew Morton <akpm@osdl.org> wrote:

  |=20
  |=20
  | ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.3-rc1=
/2.6.3-rc1-mm1/
  |=20
  |=20
  | - NFSD update
  |=20

Starting with 2.6.3-rc1-mm1, nfsd isn't working any more. Exportfs just han=
gs.
Previous version (2.6.2-mm1) worked fine.
Reverting the following patches makes it work again:

nfsd-01-schedule-in-spinlock-fix.patch
nfsd-02-ip_map_init-kmalloc-check.patch
nfsd-03-sunrpc-cache-init-fixes.patch
nfsd-04-convert-proc-to-seq_file.patch
nfsd-05-no-procfs-build-fix.patch

You can find my .config here:

http://philou.org/linux/2.6.3-rc1-mm1/config-2.6.3-rc1-mm1

You can find an strace of the nfsd server startup as well as a sysrq-t capt=
ure here:

http://philou.org/linux/2.6.3-rc1-mm1/nfsd-sysrq.txt

System is a Dell 2650 SMP (ia32), running Debian Sid.

Thanks,

Philippe

--

Philippe Gramoull=E9
philippe.gramoulle@mmania.com
Senior System and Network Architect
Lycos Europe


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
