From: "John Que" <qwejohn@hotmail.com>
Subject: usr/sbin/rpc.mountd and mountd of a build
Date: Tue, 05 Oct 2004 16:46:42 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <BAY14-F26idcDjoYAPN00000331@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CEr0F-00049J-DU
	for nfs@lists.sourceforge.net; Tue, 05 Oct 2004 08:13:23 -0700
Received: from bay14-f26.bay14.hotmail.com ([64.4.49.26] helo=hotmail.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CEqyY-00026G-No
	for nfs@lists.sourceforge.net; Tue, 05 Oct 2004 08:13:23 -0700
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

Hello,

I have nfs-utils-1.0.1-3.9 intalled (rpm) on RedHat 9;

One of the files belongiong to this rpm is rpc/mountd ; it's located in
/usr/sbin/rpc.mountd

I had build the nfs-utils-1.0.6.tar.gz by standard ./configure && make
the file rpc.mountd does not exist in the build tree; there is
a file named mountd under /utils/mountd

I suspect they are the same file; am I right ?
why is it named rpc.mountd and not mountd ?
If I'll to make install , will it copy mountd to /usr/sbin/rpc.mountd
(I want to aboid make install currently)

regards,
John

_________________________________________________________________
MSN 8 with e-mail virus protection service: 2 months FREE* 
http://join.msn.com/?page=features/virus



-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
