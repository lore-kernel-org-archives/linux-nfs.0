From: Chip Salzenberg <chip@pobox.com>
Subject: DOS bug in 1.0.5 mountd DNS code [ard@kwaak.net: rpc.mountd SEGVs (found the bug)]
Date: Tue, 9 Sep 2003 11:29:27 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030909152927.GD2460@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19wkRB-0007TX-00
	for <nfs@lists.sourceforge.net>; Tue, 09 Sep 2003 08:29:49 -0700
Received: from tandu.perlsupport.com ([66.220.6.226] ident=mail)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.22)
	id 19wkR9-000251-QO
	for nfs@lists.sourceforge.net; Tue, 09 Sep 2003 08:29:47 -0700
Received: from tytlal.hmsonline.com
	([207.43.94.202] helo=tytlal ident=mail)
	by tandu.perlsupport.com with asmtp (Exim 3.35 #1 (Debian))
	id 19wkQd-0003sR-00
	for <nfs@lists.sourceforge.net>; Tue, 09 Sep 2003 08:29:15 -0700
Received: from chip by tytlal with local (Exim 3.35 #1 (Debian))
	id 19wkQq-0004AV-00
	for <nfs@lists.sourceforge.net>; Tue, 09 Sep 2003 11:29:28 -0400
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Looks like mountd crashes when the client has no forward DNS to match
its reverse DNS.  I'll patch it.

This bug probably qualifies as important enough to release 1.0.6,
since it's a potential DOS.  After all, a client may deliberately
access a server *because* that client has no matching DNS, causing
a server crash.

I don't know if this bug has anything to do with the crashes that are
fixed by the pthread.so LD_PRELOAD, but Ard's machine *is* SMP....


----- Forwarded message from Ard van Breemen <ard@kwaak.net> -----

Subject: Bug#209318: rpc.mountd SEGVs (found the bug)
From: Ard van Breemen <ard@kwaak.net>
To: 209318@bugs.debian.org
Date: Tue, 9 Sep 2003 15:56:01 +0200

Some more info:
Before the crashing started:
Sep  9 09:30:26 upa001 rpc.mountd: Fake hostname capio-6d099b.ws.alkmaar.upa.nl for 192.168.1.252 - forward lookup doesn't match reverse 
Sep  9 09:30:26 upa001 rpc.mountd: authenticated mount request from 192.168.1.252:635 for /var/lib/diskless/scratch/192.168.1.252 (/var/lib/diskless/scratch/192.168.1.252
Sep  9 09:30:26 upa001 rpc.mountd: Fake hostname capio-6d099b.ws.alkmaar.upa.nl for 192.168.1.252 - forward lookup doesn't match reverse 
Sep  9 09:30:26 upa001 rpc.mountd: authenticated mount request from 192.168.1.252:648 for /var/lib/diskless/scratch/192.168.1.252/swap (/var/lib/diskless/scratch/192.168.
Sep  9 09:30:27 upa001 rpc.mountd: Fake hostname capio-6d099b.ws.alkmaar.upa.nl for 192.168.1.252 - forward lookup doesn't match reverse 
Sep  9 09:30:27 upa001 rpc.mountd: authenticated mount request from 192.168.1.252:651 for /var/lib/opnames (/var/lib/opnames) 

That was correct. capio-6d099b.ws.alkmaar.upa.nl was pointing to something
different then 192.168.1.252. The reversed was correct.  I then deleted the
capio-6d099b.ws.alkmaar.upa.nl entries from the dns (using nsupdate), and
then rebooted the client. No new dns entries were made. The client tried to
mount something at a time where the reversed existed, but the forward
didn't.

Hmmm, ok, found it:
nfs-utils-1.0.5/support/export/hostname.c
get_reliable_hostbyaddr(const char *addr, int len, int type)
{
<snip>
        if (tmpname) {
                forward = gethostbyname(tmpname);
                free(tmpname);
        }
        if (forward) {
<snip>
        }
        else {
                /* never heard of it. misconfigured DNS? */
                xlog(L_WARNING, "Fake hostname %s for %s - forward lookup
doesn't exist",
                     forward->h_name, inet_ntoa(*(struct in_addr*)addr));
                return NULL;
        }

So, what we see here is that it tries to print the Fake hostname using
forward->h_name, and forward==NULL.

-- 
mail          up   21+16:44,    11 users,  load 0.01, 0.05, 0.10
Let your government know you value your freedom: sign the petition:
http://petition.eurolinux.org



----- End forwarded message -----

-- 
Chip Salzenberg               - a.k.a. -               <chip@pobox.com>
"I wanted to play hopscotch with the impenetrable mystery of existence,
    but he stepped in a wormhole and had to go in early."  // MST3K


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
