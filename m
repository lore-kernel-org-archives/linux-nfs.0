From: "Magnus Naeslund\(f\)" <mag@fbab.net>
Subject: Re: Journaling FileSystems w/ NFS
Date: Fri, 20 Sep 2002 18:56:14 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <0d5b01c260c6$a17cd8a0$f80c0a0a@mnd>
References: <Pine.LNX.4.33.0209201145290.16674-100000@node1.nacs.net> <0cea01c260c2$7fb119b0$f80c0a0a@mnd>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail2.fbab.net ([195.54.134.228])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17sR4d-0000Mm-00
	for <nfs@lists.sourceforge.net>; Fri, 20 Sep 2002 09:56:11 -0700
To: "Greg Boehnlein" <damin@nacs.net>
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

Magnus Naeslund(f) <mag@fbab.net> wrote:
> Greg Boehnlein <damin@nacs.net> wrote:
>> Hello,
[snip]
>=20
> Could you elaborate on what troubles you've had?
> I'm running several boxes that have 1TB partitions and run ReiserFS.
>=20
> One looks like this:
>=20
> [root@fet1a root]# mount
> /dev/hda6 on / type ext3 (rw,noatime)
> /dev/sda1 on /storage/disk1 type reiserfs (rw,noatime,notail)
> /dev/sdb1 on /storage/disk2 type reiserfs (rw,noatime,notail)
>=20
> [root@fet1a root]# df -ht reiserfs
> Filesystem            Size  Used Avail Use% Mounted on
> /dev/sda1             1.0T  809G  260G  76% /storage/disk1
> /dev/sdb1             1.0T   33M  1.0T   1% /storage/disk2
>=20
> Magnus
>=20

Argh!
Responding to my self...

This system is an vanilla RH 7.3 system also.
I just created a 5gb fil over nfs, and it worked just fine...

Magnus



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
