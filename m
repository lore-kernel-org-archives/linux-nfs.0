From: Denis Zaitsev <zzz@anda.ru>
Subject: [BUG] Onboard Ethernet Pro 100 on a SMP box: a very strange errors
Date: Sat, 22 Jan 2005 01:46:46 +0500
Message-ID: <20050122014646.A1038@natasha.ward.six>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-net@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cs5gN-0002ta-CA
	for nfs@lists.sourceforge.net; Fri, 21 Jan 2005 12:47:03 -0800
Received: from [83.146.86.58] (helo=mail.ward.six)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1Cs5gK-0007VF-Nb
	for nfs@lists.sourceforge.net; Fri, 21 Jan 2005 12:47:03 -0800
To: linux-kernel@vger.kernel.org
Sender: nfs-admin@lists.sourceforge.net
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

The long story is:

There is a Dual-processor Intel Server Board STL2 with two P-III/800
and an onboard Intel 82557-based ethernet card.  The box has all the
/usr and nearly all of the /var filesystems mounted over NFS.  And the
box works for months without any problems around the NFS.  So, I think
that the ethernet card just works fine.

But I have some enigmatic problems when I copying _some_ files from an
NFS to the local fs: the process is freezes on the middle.

1) Only _some_ files can't be copied.  There are:

   gcc-testsuite-3.4-20041217.tar.bz2

   krb5-1.3.6-signed.tar

   X430src-1.tgz

   They are the well-known sources from the well-known ftp and web
   places.  And I don't think that it's the full list, just the files
   for which I have met the problem.

2) Only _these_ files can't be copied.  Any other is copied plainly.

3) These files _never_ can be copied.

4) The copy process always freezes at the same place (per file - the
   each file has its own place).

In short: it's a list of files, on which the copying is always freezes
and always freezes exactly the same way.  And there are no any
exception - I have freezeng each time.

The freezing is forever.  The freezed process is in D state, its
/proc/PID/wchan contains page_sync.  Each such process eats 1.0 from
/proc/loadavg.  And the process can't be killed by any signal.

Then, copying by dd bs=1024 ... just succeeds.  After that cp succeeds
too - I think it's because of caching.

Then, there is no visual correlation with the size of the file.  So,
it seems that the content of the file is involved...  But it is
enigmatic.

The NIC works fine all the other time, so there no suspicions about
hardware problems.

The other NIC - 3C905 PCI external card doesn't show the problem - all
the files are just copied.

An either driver for Ethernet Pro 100 - e100 or eepro100 - show the
same result, but eepro100 logs periodicaly:

        eth0: wait_for_cmd_done timeout!

e100 logs nothing.

So, it doesn't ever look like a driver bug...

The kernels tested: 2.6.8.1, 2.6.9, 2.6.10.

GLIBC used: 2.3.2.


-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
