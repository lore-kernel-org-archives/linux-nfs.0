From: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
Subject: server freeze with 2.6.8.1
Date: Wed, 08 Sep 2004 09:32:52 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <413EB5A4.9040505@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C4wws-0003PZ-3V
	for nfs@lists.sourceforge.net; Wed, 08 Sep 2004 00:32:58 -0700
Received: from acheron.informatik.uni-muenchen.de ([129.187.214.135])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1C4wwq-0007mU-5M
	for nfs@lists.sourceforge.net; Wed, 08 Sep 2004 00:32:57 -0700
Received: from internaldeliver.acheron.informatik.uni-muenchen.de (localhost [127.0.0.1])
	by acheron.informatik.uni-muenchen.de (Postfix) with ESMTP id 50F474357E
	for <nfs@lists.sourceforge.net>; Wed,  8 Sep 2004 09:32:53 +0200 (CEST)
Received: from [141.84.1.141] (galois.bio.ifi.lmu.de [141.84.1.141])
	(using TLSv1 with cipher RC4-MD5 (128/128 bits))
	(No client certificate requested)
	by acheron.informatik.uni-muenchen.de (Postfix) with ESMTP id 48A5F4357C
	for <nfs@lists.sourceforge.net>; Wed,  8 Sep 2004 09:32:53 +0200 (CEST)
To: nfs@lists.sourceforge.net
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

Hi,

I know that the following description is not helpful for reproducing
the freeze, but I'm hoping that someone might have encountered something
similar or has an idea...

Our NFS server serves about 60 clients, 25 of them with root-over-nfs,
the rest just gets some stuff like /home etc. We recently switched from
2.4.21 to 2.6.8.1 and use self-compiled kernel rpms (based on the SuSE
rpms). We installed some kernel upgrades in the last weeks, all 2.6.8.1 based,
but enhanced by some security fixes or patches like packet writing etc.
So we got versions 2.6.8.1-1 to -3 which differed just in the security
fixes nfsd-xdr-patch, reiserfs-xattr-acl.patch, as well as the cdwriting-
patch. So basically the same kernels.

During these updates and reboots we encoutered some mysterious server
freezes. They are  not 100% reproducible, but when they happened we
had always installed a new kernel rpm on the server (in parallel to the
old ones, so that diskless clients keep the needed /lib/modules/ until they
reboot) and then either

- rebooted several clients in parallel to the new kernel while the
   server is still running the older version.

- or had the server (and some clients) run the new version and then
   rebooted some clients which are still running the old version.

We had also one situation where a user logged in into a client with KDE and
the server froze. The first time this happened, the client had just
booted to the new version that the server was already running. The freeze
then happened 4 times in a row when the user logged in, until we cleaned
up all kde-related files and directories on that users home (hosted on
the nfs server).

When the freeze occurs, the nfs server does not give any message on
/dev/tty10. No kernel oops or sth. Sometimes, when I'm quick enough,
I can still switch between consoles, e.g., from tty10 to tty1 and
back, but trying e.g. a emergency sync will then freeze the server
completely,  so that not even alt+sysrq+b will work. The last messages
I see in /var/log/messages are always the messages that a client has
mounted the nfs directories.

We are using nfs v3 with tcp,hard,intr,lock.

We had the same problem already when running the official SuSE kernel
2.4.21-xxx (never before with 2.4.19 and 2.4.20), where the nfs server
would freeze the same way, and that happened to nfs servers running
an i386 and IBM pSeries (SLES 8), but it happened not that often.

Now that I turned on /proc/sys/sunrpc/rpc_debug and /proc/sys/sunrpc/nfsd_debug
it could (of course) not reproduce the freeze again by booting back and
forth with the different versions.
Maybe it happens only after the server had run for some days (kind
of a pollution effect...?).

I can try to keep /proc/sys/sunrpc/rpc_debug and nfsd_debug running,
although it causes such a lot of messages that the disk performance
of the server really goes down. Would those debugging messages help
at all of the freeze occured again?

Or is there something else I can try? Has anyone seen sth. similar?

cu,
Frank

-- 
Dipl.-Inform. Frank Steiner   Web:  http://www.bio.ifi.lmu.de/~steiner/
Lehrstuhl f. Bioinformatik    Mail: http://www.bio.ifi.lmu.de/~steiner/m/
LMU, Amalienstr. 17           Phone: +49 89 2180-4049
80333 Muenchen, Germany       Fax:   +49 89 2180-99-4049
* Rekursion kann man erst verstehen, wenn man Rekursion verstanden hat. *


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
