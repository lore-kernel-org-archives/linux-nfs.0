From: Tobias Diedrich <ranma@tdiedrich.de>
Subject: NFSv3, 2.6, ext3 and dir_index
Date: Thu, 20 Jan 2005 17:38:06 +0100
Message-ID: <20050120163806.GA25242@melchior.yamamaya.is-a-geek.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="zYM0uCDKw75PZbzx"
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CrfK6-0003ZP-Ua
	for nfs@lists.sourceforge.net; Thu, 20 Jan 2005 08:38:18 -0800
Received: from lum.tdiedrich.de ([193.24.211.71] ident=postfix)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1CrfK4-0002h7-0s
	for nfs@lists.sourceforge.net; Thu, 20 Jan 2005 08:38:18 -0800
To: nfs@lists.sf.net
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


--zYM0uCDKw75PZbzx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

I recently switched from a local homedir to a NFS mounted homedir
and noticed some strange things:

I have a Cronjob that goes over my mp3 directory and after the
switch find would print "foo/bar/blubb: No such file or directory"
for a few (approx. 2-3 out of 1928) directories, but not always the same
ones.  Also, my mp3 player program would sometimes stop short in the
middle of a song and skip to the next one, because it got ENOENT on
a read of an open file.

Now first I thought it might just be a problem with my Kernel
version or one of the patches I'm using and upgraded to a more
recent one (currently 2.6.10-ac8-nfsacl on the client and
2.6.10-ac8-imq-nfsacl on the server, I also had the same problem
without the nfsacl patches).

Then I read an older thread about trouble with ext3/dir_index and
NFS in older 2.6 versions and tried disabling dir_index (Which was
enabled on all my ext3 filesystems).  With that the problem
vanished.

Are there any known problems with dir_index and NFS, or is this
maybe a new bug?

Getting a tcpdump of the client<->server traffic proved difficult,
because it is a quite sporadic bug and reproducing it would involve
quite a lot of NFS traffic.  I could reliably trigger this with my
CD/DVD burning script, which generates md5sums for each file and
puts them both into the file MD5SUMS in the current directory, as
well as into another file in my Homedir (But the files being
md5summed also live on another NFS export, so there is a _lot_ of
traffic).

I _do_ have a traffic capture of ls returning "No such file or
directory" on the current directory, then cding up a level, down into the
directory again and then a working ls.

Client fstab entry:
nukunuku:/mnt/space1/ranma /home/ranma nfs hard,intr,bg,udp,rsize=4096,wsize=4096 0 0

/proc/mounts entry:
nukunuku:/mnt/space1/ranma /home/ranma nfs rw,v3,rsize=4096,wsize=4096,hard,intr,udp,lock,addr=nukunuku 0 0

Server export file:
/ melchior.yamamaya.is-a-geek.org(sync,rw,no_root_squash)
/mnt/space1 melchior.yamamaya.is-a-geek.org(sync,rw,no_root_squash)
/mnt/space2 melchior.yamamaya.is-a-geek.org(sync,rw,no_root_squash)
/mnt/space3 melchior.yamamaya.is-a-geek.org(sync,rw,no_root_squash)

-- 
Tobias						PGP: http://9ac7e0bc.uguu.de

--zYM0uCDKw75PZbzx
Content-Type: application/octet-stream
Content-Disposition: attachment; filename="nfs.tcpdump.gz"
Content-Transfer-Encoding: base64

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

--zYM0uCDKw75PZbzx--


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
