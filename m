From: Bernd Schubert <bernd-schubert@web.de>
Subject: async vs. sync
Date: Mon, 26 Jul 2004 17:17:59 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200407261718.03264.bernd-schubert@web.de>
References: <200407231620.i6NGKYV20945@algebra.hillsboro.credence.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bp7F0-0006LH-8R
	for nfs@lists.sourceforge.net; Mon, 26 Jul 2004 08:18:14 -0700
Received: from smtp06.web.de ([217.72.192.224])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1Bp7Ez-0001Hx-RH
	for nfs@lists.sourceforge.net; Mon, 26 Jul 2004 08:18:14 -0700
Received: from [80.140.20.159] (helo=bathl.lan.fli4l)
	by smtp06.web.de with asmtp (TLSv1:RC4-MD5:128)
	(WEB.DE 4.101 #44)
	id 1Bp7Eq-00071R-00
	for nfs@lists.sourceforge.net; Mon, 26 Jul 2004 17:18:04 +0200
To: Linux NFS Mailing List <nfs@lists.sourceforge.net>
In-Reply-To: <200407231620.i6NGKYV20945@algebra.hillsboro.credence.com>
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


> On a completely seperate note, Linux-to-Linux NFS file writes
> only seem to be fast if we publish the serving Linux volume
> as asynchronous (default setting is synchronous which is slow).
>

Yeah, we just observed something similar.=20

Here some numbers for write speed of the clients:

linux-2.6.7:
async: 11MB/s
sync, wdelay: 2-3MB/s
sync, no_wdelay: 7MB/s

linux-2.4.27-rc3:
async: 11MB/s
sync, wdelay: 2-3MB/s
sync, no_wdelay: 2-3MB/s

The kernel version corresponds to the server kernel, all clients still run=
=20
2.4.26.

Unfortunality switching the server to 2.6.7 makes the server crash every=20
morning on running the cron-jobs with page allocation errors, so keeping=20
2.6.x is currently not an option. At least not as long as those errors seem=
=20
to be tolerated by the kernel maintainers :(

Any ideas whats the issue with sync vs async in 2.4.x?

Thanks,
	Bernd




=2D-=20
Bernd Schubert
Physikalisch Chemisches Institut / Theoretische Chemie
Universit=E4t Heidelberg
INF 229
69120 Heidelberg
e-mail: bernd.schubert@pci.uni-heidelberg.de




-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
