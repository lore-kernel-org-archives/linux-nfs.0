From: Olaf Kirch <okir@suse.de>
Subject: Re: Linux' NFS locking b0rken?
Date: Tue, 25 May 2004 14:34:25 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040525123425.GO21886@suse.de>
References: <1085487829.6666.32.camel@tesla.mmt.bellhowell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BSbB0-0000qw-1q
	for nfs@lists.sourceforge.net; Tue, 25 May 2004 05:37:02 -0700
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1BSbAz-0006iM-BN
	for nfs@lists.sourceforge.net; Tue, 25 May 2004 05:37:01 -0700
To: Jeffrey Layton <jtlayton@poochiereds.net>
In-Reply-To: <1085487829.6666.32.camel@tesla.mmt.bellhowell.com>
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

On Tue, May 25, 2004 at 08:23:49AM -0400, Jeffrey Layton wrote:
> if ( flock(FH, LOCK_EX|LOCK_NB) ) {

BSD flock locks have never worked over NFS, and probably will
never work over NFS. Please use POSIX (i.e. fcntl) locks instead.

Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
