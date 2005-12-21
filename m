From: Kenny Simpson <theonetruekenny@yahoo.com>
Subject: Re: kernel BUG at fs/locks.c:1932!
Date: Tue, 20 Dec 2005 19:20:46 -0800 (PST)
Message-ID: <20051221032046.17277.qmail@web34102.mail.mud.yahoo.com>
References: <1135133642.7937.22.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EouX7-000449-GL
	for nfs@lists.sourceforge.net; Tue, 20 Dec 2005 19:20:53 -0800
Received: from web34102.mail.mud.yahoo.com ([66.163.178.100])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1EouX6-0005Gh-5S
	for nfs@lists.sourceforge.net; Tue, 20 Dec 2005 19:20:53 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1135133642.7937.22.camel@lade.trondhjem.org>
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

> Hmm... That indicates that some posix locks are somehow still managing
> to survive a close().
>=20
> How did you trigger this problem? Were you signalling the process?

I was not, but I think the tests end by killing the worker threads.
I'll run it again tomorrow.  The options were '0 0 64k 4G 20 1' - from me=
mory.
No random reads or writes, 64k block size, 4GB file, 20 seconds duration,=
 1 thread.

I did not notice this when running the test... only noticed a bunch of th=
ese later in the syslog.

-Kenny


__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around=20
http://mail.yahoo.com=20


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log fi=
les
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=3D7637&alloc_id=3D16865&op=3Dclick
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
