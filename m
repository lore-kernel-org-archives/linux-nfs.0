From: "Serge Sozonoff" <serge@sozonoff.com>
Subject: NFS and linux 2.6 series kernels
Date: Mon, 8 Mar 2004 13:09:36 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <000501c40506$39975c20$6402a8c0@GE30303>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B0JiE-0008WF-7C
	for nfs@lists.sourceforge.net; Mon, 08 Mar 2004 04:18:26 -0800
Received: from mail.freezefotoz.com ([213.221.158.23] helo=gentoo.sozonoff.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1B0Ja1-000604-Se
	for nfs@lists.sourceforge.net; Mon, 08 Mar 2004 04:09:58 -0800
To: <nfs@lists.sourceforge.net>
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

Hi All,

Does anyone have an NFS client (v3) on a 2.6 series linux kernel performing
well for large file transfers ?

Whenever I do a transfer the transfer starts fine with a good rate and then
grinds to a halt and kind of continues in bursts.
In the log file I see entries like the following :

Mar  8 05:10:37 sui75 kernel: nfs warning: mount version older than kernel
Mar  8 05:12:00 sui75 kernel: nfs: server nas not responding, still trying
Mar  8 05:12:01 sui75 kernel: nfs: server nas not responding, still trying
Mar  8 05:12:02 sui75 kernel: nfs: server nas OK
Mar  8 05:12:02 sui75 kernel: nfs: server nas OK
Mar  8 05:12:27 sui75 kernel: nfs: server nas not responding, still trying
Mar  8 05:12:45 sui75 last message repeated 2 times
Mar  8 05:12:45 sui75 kernel: nfs: server nas OK
Mar  8 05:12:45 sui75 last message repeated 2 times

If I take the exact same client machine and reboot it with a 2.4 kernel the
transfer happens smoothly. I have tried various versions of the 2.6 kernel.
I am using the Gentoo distro.
I have seen various other posts around the web where people seem to be
experiencing similar things.
Is my safest bet to stick to 2.4 ?

Thanks,
Serge



-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
