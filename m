From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH]  Reinstantiating stale inodes
Date: Sat, 01 May 2004 19:57:48 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <4094397C.3030303@RedHat.com>
References: <40892507.2030004@RedHat.com>  <4093CCB6.1040500@RedHat.com> <1083439518.3687.19.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BK4Mp-0007CV-9U
	for nfs@lists.sourceforge.net; Sat, 01 May 2004 16:57:59 -0700
Received: from mx2.redhat.com ([66.187.237.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BK4Mp-0008O9-6z
	for nfs@lists.sourceforge.net; Sat, 01 May 2004 16:57:59 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1083439518.3687.19.camel@lade.trondhjem.org>
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

Trond Myklebust wrote:

>You are not listening to what I am saying: you are NOT allowed to change
>inodes in this manner. The filehandle defines which file you are
>referencing. By changing the filehandle, you are changing files from
>beneath other processes and your own process.
>  
>
Believe me... I hear you.... and do understand what I'm trying to do....
And I also apologize for being so persistent.... but just bothers the
hell out of me that other clients can recover from ESTALEs and we don't...

>Imagine if I do
>
>rm blah; ln /etc/passwd blah
>
>Your patch means that anyone that was writing to file "blah" before you
>deleted it, will suddenly find themselves overwriting /etc/passwd. That
>is NOT POSIX-compatible behaviour!
>  
>
I see this point in theory, but in my testing, bad things don't seem to 
happen.
The writes always fails with ESTALE... but I can't deny there is not a 
window
just because I can't reproduce it...

>The ONLY way to overcome a stale inode is to d_drop() the dentry, unhash
>the inode, and then force the VFS to look up a new inode. That way only
>new calls to open() end up overwriting /etc/passwd in the above case.
>  
>
I guess I would be interested on how other implementation handle this 
problem,
since they seem to recover... Maybe their VFS layers is more friendly to
these types of things....

SteveD.



-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
