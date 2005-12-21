From: Kenny Simpson <theonetruekenny@yahoo.com>
Subject: Re: NFS TCP settings
Date: Wed, 21 Dec 2005 08:32:54 -0800 (PST)
Message-ID: <20051221163254.70779.qmail@web34105.mail.mud.yahoo.com>
References: <1135093627.7955.36.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ep6th-0001At-9h
	for nfs@lists.sourceforge.net; Wed, 21 Dec 2005 08:33:01 -0800
Received: from web34105.mail.mud.yahoo.com ([66.163.178.103])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1Ep6tg-0001vM-V6
	for nfs@lists.sourceforge.net; Wed, 21 Dec 2005 08:33:01 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1135093627.7955.36.camel@lade.trondhjem.org>
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
> The NFS/RPC code has no direct control over the TCP window size. That
> would be an issue for the networking people.

I have tracked this a bit further, and am reporting back for completeness=
..

The version of OnTap we are using (6.4.1p1) does not seem to support RFC =
1323 (large TCP windows),
but the Linux client does.  The window scaling is communicated in the ini=
tial connection (SYN), so
if ethereal does not catch that, it will incorrectly report the window si=
ze as the unscaled number
- making the Linux client appear to be using a very small window.
The reason it appeared that the small window size was being honored is a =
result of the direct
crossover cable making the BDP (bandwidth-delay product) very small.

As for the server side, because large TCP windows are not supported, the =
best it can do is 64k -
which it does.  Running with GbE and jumbo packets fills the window quite=
 fast obviating the need
for RFC 1323.

Thanks to those who took the time to swing a clue stick in my direction.

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
