From: Jeffrey Layton <jtlayton@poochiereds.net>
Subject: Re: Linux' NFS locking b0rken?
Date: Tue, 25 May 2004 12:42:09 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1085503328.13681.4.camel@tesla.mmt.bellhowell.com>
References: <1085487829.6666.32.camel@tesla.mmt.bellhowell.com>
	 <20040525123425.GO21886@suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BSf0G-0004zx-RD
	for nfs@lists.sourceforge.net; Tue, 25 May 2004 09:42:12 -0700
Received: from rdu26-93-067.nc.rr.com ([66.26.93.67] helo=salusa.poochiereds.net)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BSf0G-0001CL-H4
	for nfs@lists.sourceforge.net; Tue, 25 May 2004 09:42:12 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040525123425.GO21886@suse.de>
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

On Tue, 2004-05-25 at 08:34, Olaf Kirch wrote:
> BSD flock locks have never worked over NFS, and probably will
> never work over NFS. Please use POSIX (i.e. fcntl) locks instead.
> 
> Olaf

Ahh I learned something new today! I didn't realize there were 2 locking
implementations. I ended up writing a small C program to test this, and
fcntl locks do seem to work over NFS.

Perhaps Solaris does some sort of BSD-POSIX lock translation which makes
flock() work there?

Thanks for the info!
-- Jeff




-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
