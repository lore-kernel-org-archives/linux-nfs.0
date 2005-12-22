From: Kenny Simpson <theonetruekenny@yahoo.com>
Subject: Re: kernel BUG at fs/locks.c:1932!
Date: Thu, 22 Dec 2005 12:35:16 -0800 (PST)
Message-ID: <20051222203516.69284.qmail@web34107.mail.mud.yahoo.com>
References: <1135133642.7937.22.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-list1-b.sourceforge.net ([10.3.1.7] helo=sc8-sf-list1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EpX9q-0004ce-FG
	for nfs@lists.sourceforge.net; Thu, 22 Dec 2005 12:35:26 -0800
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 4.30)
	id 1EpX9p-0003jN-RM
	for nfs@lists.sourceforge.net; Thu, 22 Dec 2005 12:35:25 -0800
Received: from web34107.mail.mud.yahoo.com ([66.163.178.105])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1EpX9o-0001GJ-JL
	for nfs@lists.sourceforge.net; Thu, 22 Dec 2005 12:35:25 -0800
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

--- Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> Hmm... That indicates that some posix locks are somehow still managing
> to survive a close().
>=20
> How did you trigger this problem? Were you signalling the process?

I have not been able to reproduce this.  I only noticed this the first ti=
me after running many
tests, and some time later observing the syslog.

It looks like this may have been fixed anyway by ASANO Masahiro:
http://www.ussg.iu.edu/hypermail/linux/kernel/0512.2/1531.html

-Kenny



	=09
__________________________________________=20
Yahoo! DSL =96 Something to write home about.=20
Just $16.99/mo. or less.=20
dsl.yahoo.com=20



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log fi=
les
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=3D7637&alloc_id=3D16865&op=3Dclick
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
