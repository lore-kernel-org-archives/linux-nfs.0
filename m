From: Filipe Brandenburger <branden@terra.com.br>
Subject: Stale NFS file handle
Date: Tue, 22 Mar 2005 21:19:20 -0300
Message-ID: <20050322210033.BEAC.BRANDEN@terra.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DDtaB-0006ey-6S
	for nfs@lists.sourceforge.net; Tue, 22 Mar 2005 16:18:47 -0800
Received: from itapoa.terra.com.br ([200.154.55.227])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DDtZv-00048O-Dt
	for nfs@lists.sourceforge.net; Tue, 22 Mar 2005 16:18:47 -0800
Received: from talara.terra.com.br (talara.terra.com.br [200.154.55.136])
	by itapoa.terra.com.br (Postfix) with ESMTP id 78F9030C43B
	for <nfs@lists.sourceforge.net>; Tue, 22 Mar 2005 21:18:27 -0300 (BRT)
Received: from [200.176.1.176] (branden.terra.com.br [200.176.1.176])
	(authenticated user branden)
	by talara.terra.com.br (Postfix) with ESMTP id 5694E14C038
	for <nfs@lists.sourceforge.net>; Tue, 22 Mar 2005 21:18:27 -0300 (BRT)
To: nfs@lists.sourceforge.net
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


Hello,

I have a problem where I'm getting "Stale NFS file handle" errors when a
file is updated. I can easily reproduce the problem if I run a sequence
of commands in two different hosts.

My environment is:

1) Server: Netapp FAS940
2) Client 1: Linux RedHat 9 with kernel 2.4.21-4.ELsmp (kernel of RHAS3)
3) Client 2: exactly the same as client 1.

The file system is mounted on both clients with the options
rsize=8192,wsize=8192,timeo=28,intr, additionally it's mounted read-only
on client 2 (it also gives me stale file handle if it's mounted
read-write, so it doesn't really matter).

My test setup is:

On client 2, I setup a loop to read a file:

# while :; do cat test.txt; done >/dev/null

Then, on client 1, I create a new file and rename it over the original
file:

# date >new.txt; mv -f new.txt test.txt

Whenever I execute this on client 1, I get the following error message
on client 2:

cat: test.txt: Stale NFS file handle



Why is this happening? Is there a way to fix this problem? I tried the
mount options "noac" and "nocto" on client 2, and used "mount -o remount"
on it, after that the output of "mount" returned these options, and it
didn't solve the issue.

Is there a way to solve this issue without changing applications that
access this file? Because although my test environment consists of only
"cat" and "mv", my real production environment is of proprietary
applications, that are harder to fix, "cat" and "mv" was only the way I
used to reproduce the problem in a controlled environment...

Thanks a lot,
Filipe



-------------------------------------------------------
This SF.net email is sponsored by: 2005 Windows Mobile Application Contest
Submit applications for Windows Mobile(tm)-based Pocket PCs or Smartphones
for the chance to win $25,000 and application distribution. Enter today at
http://ads.osdn.com/?ad_id=6882&alloc_id=15148&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
