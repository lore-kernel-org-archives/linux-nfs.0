From: Philippe =?ISO-8859-15?Q?Gramoull=E9?= <philippe.gramoulle@mmania.com>
Subject: Re: 2.6.3-rc1-mm1
Date: Mon, 9 Feb 2004 15:26:42 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040209152642.22dc457e@philou.gramoulle.local>
References: <20040209014035.251b26d1.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-list1-b.sourceforge.net ([10.3.1.7] helo=sc8-sf-list1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AqNQo-0001sx-Fs
	for nfs@lists.sourceforge.net; Mon, 09 Feb 2004 18:15:22 -0800
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 4.30)
	id 1AqCOj-0007ff-Tf
	for nfs@lists.sourceforge.net; Mon, 09 Feb 2004 06:28:29 -0800
Received: from pgramoul.net2.nerim.net ([80.65.227.234] helo=philou.aspic.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AqCOc-0007Hq-OJ
	for nfs@lists.sourceforge.net; Mon, 09 Feb 2004 06:28:29 -0800
Received: from philou.gramoulle.local (philou.gramoulle.local [192.168.254.2])
	by philou.aspic.com (Postfix) with SMTP id DEA7B13AC5
	for <nfs@lists.sourceforge.net>; Mon,  9 Feb 2004 15:26:42 +0100 (CET)
To: nfs <nfs@lists.sourceforge.net>
In-Reply-To: <20040209014035.251b26d1.akpm@osdl.org>
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


Sorry, i forgot to CC: this list.

Thanks,

Philippe


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
