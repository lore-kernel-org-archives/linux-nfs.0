From: Audun Arnesen Nordal <audun@stud.cs.uit.no>
Subject: stale nfshandles in linux 2.2.17
Date: Wed, 20 Mar 2002 13:31:30 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0203191708190.26134-100000@lgserv3.stud.cs.uit.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Received: from lgserv3.stud.cs.uit.no ([129.242.13.151])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16nfFe-0007X0-00
	for <nfs@lists.sourceforge.net>; Wed, 20 Mar 2002 04:31:34 -0800
Received: from localhost (audun@localhost)
	by lgserv3.stud.cs.uit.no (8.11.6/8.11.6) with ESMTP id g2KCVUZ22515
	for <nfs@lists.sourceforge.net>; Wed, 20 Mar 2002 13:31:30 +0100
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


Please forgive me if this is not the proper place to post questions like 
this.

I have a Raidzone Opennas box that came with a 2.2.17 kernel, seemingly
based on a redhat 6.1 or 6.2 distribution. The filesystem I wish to export
is ReiserFS 3.5.25. The host contains special IDE-diskraid hardware and a
kernel that came with the box, thus I cannot easily recompile the sources.

I am trying to build a very light-weight userland nfsv2 client (don't ask 
why, it's a long story), and run into problems when I try to talk nfs with 
this particular machine (against BSD's things run fine).

nfssrv # uname -a
Linux vstore 2.2.17-22.0 #1 Thu Apr 19 13:23:33 EDT 2001 i686 
unknown

nfssrv # cat /etc/exports
/wideopen nfsclnt(rw,insecure,insecure_locks,all_squash,anonuid=99,
anongid=99)

This is how far I get: I can mount /wideopen on the client side, and I can 
getattr the initial filehandle and do a lookup(filehandle, ".") without 
problem. I run into problems however when I create a file or directory on 
the host. Below is a pseudo-trace of what happens on the client side 
(syntax 'client command' -> 'server reply'):

mount('nfssrv:/wideopen') -> rootfh (for example 
1000000041f3000000000000144700001447000041f300002000000020000000)
create('test') -> fh (for example 
200000007bf3000041f30000144700001447000041f3000041f3000041f30000)
getattr(fh) -> NFSERR_STALE
lookup(rootfh, 'test') -> NFSERR_ENOENT

I.e., nothing get's created on the server side, although I receive a 
seemingly good file handle. However, if I immediately after the create do 
a listdir, the 'test'-file appears:

listdir(rootfh) -> ('.', '..', 'test')

although if I do a lookup(rootfh, 'test') after this, I get NFSERR_ENOENT.

As I said, I cannot easily try new patches, but if there's no way around 
it, I will look into getting my hands on the sources. Could it be that it 
is a reiserfs issue? The filesystem is simply mounted with -o rw on the 
server.

Any hints appreciated.

Best regards


-- 
Audun Nordal




_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
