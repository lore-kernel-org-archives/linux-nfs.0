From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH]  Reinstantiating stale inodes
Date: Sat, 01 May 2004 15:25:18 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1083439518.3687.19.camel@lade.trondhjem.org>
References: <40892507.2030004@RedHat.com>  <4093CCB6.1040500@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BK06y-0006Ft-By
	for nfs@lists.sourceforge.net; Sat, 01 May 2004 12:25:20 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BK06y-0003fk-0z
	for nfs@lists.sourceforge.net; Sat, 01 May 2004 12:25:20 -0700
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <4093CCB6.1040500@RedHat.com>
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

On Sat, 2004-05-01 at 12:13, Steve Dickson wrote:

> Is this something Marcelo might be interested in?

Vetoed!

You are not listening to what I am saying: you are NOT allowed to change
inodes in this manner. The filehandle defines which file you are
referencing. By changing the filehandle, you are changing files from
beneath other processes and your own process.

Imagine if I do

rm blah; ln /etc/passwd blah

Your patch means that anyone that was writing to file "blah" before you
deleted it, will suddenly find themselves overwriting /etc/passwd. That
is NOT POSIX-compatible behaviour!

The ONLY way to overcome a stale inode is to d_drop() the dentry, unhash
the inode, and then force the VFS to look up a new inode. That way only
new calls to open() end up overwriting /etc/passwd in the above case.

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
