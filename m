From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: oops in FC1 update kernel, in refile_inode
Date: Mon, 26 Apr 2004 17:56:32 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1083016592.15282.107.camel@lade.trondhjem.org>
References: <408D7E8E.7040801@collab.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-Z+cAgSFL26r6JzXJURWC"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BIE5f-0001VM-IW
	for nfs@lists.sourceforge.net; Mon, 26 Apr 2004 14:56:39 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BIE5f-00023x-7C
	for nfs@lists.sourceforge.net; Mon, 26 Apr 2004 14:56:39 -0700
To: Andrew Ryan <andrewr@collab.net>
In-Reply-To: <408D7E8E.7040801@collab.net>
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


--=-Z+cAgSFL26r6JzXJURWC
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Mon, 2004-04-26 at 17:26, Andrew Ryan wrote:
> I realize that this list is the wrong place to go for Fedora/RH support, 
> but we're having a unpleasant problem and I'm hoping someone here could 
> shed some light on it. We're running load tests on Subversion with 
> repositories on NFS-mounted filesystems, and getting reliable oops'es 
> after a few hours-days of testing. With the repos on local disk, no 
> oops, and the tests complete normally. For all I know, the bug has 
> nothing to do with NFS, but there seems to be a correlation.
> 
> I filed a RH bugzilla issue today, which has a decoded oops, SysRq+T 
> output, and vmstat output for the period preceding the crash.
> https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=121732
> 
> The hardware is dual Xeon 3.0GHz, running hyperthreading, kernel
> 2.4.22-1.2179.nptlsmp. The mount options in use are:
> rw,tcp,nfsvers=3,rsize=32768,wsize=32768,intr
> The NFS server is a NetApp. Both NFS client and server are running at
> 100Mb switched ethernet.
> 
> In the 2.4.26 kernel's Changelog
> (http://kernel.org/pub/linux/kernel/v2.4/ChangeLog-2.4.26) I saw
> mention of a refile_inode bug fixed by Trond, which made me think
> perhaps this is what is affecting us, but I don't know. I'm all for 
> trying out pretty much any patch which might help us.

That is indeed a fix for a generic VFS/mm race. It has pretty much
nothing to do with NFS itself but just happened to trigger on an NFS
partition for someone.
As far as I can see, that patch hasn't yet been applied to the latest
errata kernel (linux-2.4.22-1.2188.nptl). Have you tried it out to see
if it fixes your Oops?

Steve, could you make sure that patch makes it into any future errata
kernels?

Cheers,
  Trond



--=-Z+cAgSFL26r6JzXJURWC
Content-Description: 
Content-Disposition: inline; filename=linux-2.4.26-refile_inode.dif
Content-Transfer-Encoding: base64
Content-Type: text/plain; charset=iso-8859-1

LS0tIGxpbnV4LTIuNC4yNi11cC9mcy9pbm9kZS5jLm9yaWcJMjAwNC0wMy0xOSAxNzoxMjo0Ni4w
MDAwMDAwMDAgLTA1MDANCisrKyBsaW51eC0yLjQuMjYtdXAvZnMvaW5vZGUuYwkyMDA0LTAzLTI2
IDEzOjAxOjIzLjAwMDAwMDAwMCAtMDUwMA0KQEAgLTMxOSw3ICszMTksOCBAQCB2b2lkIHJlZmls
ZV9pbm9kZShzdHJ1Y3QgaW5vZGUgKmlub2RlKQ0KIAlpZiAoIWlub2RlKQ0KIAkJcmV0dXJuOw0K
IAlzcGluX2xvY2soJmlub2RlX2xvY2spOw0KLQlfX3JlZmlsZV9pbm9kZShpbm9kZSk7DQorCWlm
ICghKGlub2RlLT5pX3N0YXRlICYgSV9MT0NLKSkNCisJCV9fcmVmaWxlX2lub2RlKGlub2RlKTsN
CiAJc3Bpbl91bmxvY2soJmlub2RlX2xvY2spOw0KIH0NCiANCg==

--=-Z+cAgSFL26r6JzXJURWC--


-------------------------------------------------------
This SF.net email is sponsored by: The Robotic Monkeys at ThinkGeek
For a limited time only, get FREE Ground shipping on all orders of $35
or more. Hurry up and shop folks, this offer expires April 30th!
http://www.thinkgeek.com/freeshipping/?cpg=12297
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
