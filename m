From: Per Buer <perbu@linpro.no>
Subject: Does nfsd.o handle overwriting of files properly?
Date: Fri, 13 Aug 2004 09:04:26 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200408130904.26180.perbu@linpro.no>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BvW7E-0006bv-DZ
	for nfs@lists.sourceforge.net; Fri, 13 Aug 2004 00:04:40 -0700
Received: from netstat.linpro.no ([80.232.36.140])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1BvW7D-0000xm-VT
	for nfs@lists.sourceforge.net; Fri, 13 Aug 2004 00:04:40 -0700
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

Hi.

We have a daemon which does the following. Create a new file "foo" and renames 
this file to "bar". This happens on a nfs volume. The problem seems to be 
that we get "stale NFS handle" right after "bar" is overwritten.

I guess the directory is cached and so the dentry points to an non-existing 
inode (as the old "bar" is deleted when the ref-count hits zero). 

Server: RHEL AS 2.1 (2.4.9 with lots and lots of pathes)
Client: RHEL ES 3.0 (2.4.21with lots and lots of pathes)

I fix could be to keep an link to the old "bar" hanging around for 30s or so - 
but I consider that a somewhat dirty work-around.

Is there anything else I can do to mend this?

-- 
There are only 10 different kinds of people in the world, 
those who understand binary, and those who don't.


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
