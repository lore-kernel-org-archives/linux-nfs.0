From: Matt Bernstein <mb/nfs@dcs.qmul.ac.uk>
Subject: bind mounts and rpc quotas: horrible interactions
Date: Wed, 10 Jul 2002 17:43:00 +0100 (BST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0207101732140.18902-100000@nick.dcs.qmul.ac.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from nick.dcs.qmul.ac.uk ([138.37.88.61])
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 17SKYR-0008JJ-00
	for <nfs@lists.sourceforge.net>; Wed, 10 Jul 2002 09:43:04 -0700
Received: from nick.dcs.qmul.ac.uk ([138.37.88.61])
	by nick.dcs.qmul.ac.uk with asmtp (TLSv1:EDH-RSA-DES-CBC3-SHA:168)
	(Exim 4.05)
	id 17SKYO-0000Va-00
	for nfs@lists.sourceforge.net; Wed, 10 Jul 2002 17:43:00 +0100
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

Hi,

I've only just noticed after upgrading our Debian potato server to woody
(some weeks ago) all rpc quotas are not working properly.

Our home directories are /homes/$LOGNAME where /homes is an autofs (yp)
mount. On client machines this is an NFS mount. On the server under potato
/homes contained a load of symlinks to /exportxx/users/$LOGNAME where xx
is some value. Under woody this is a bind mount. Fair enough, I think.

Client machines cannot see the quota information unless users (in their
home directory) do a "ln -s /exportxx/aquota.user". At this point they can
now interrogate their quota information--but it's not updated when they do
i/o to their home files. All of this seems wrong and horrible!

Does this even make sense to anyone? Downgrading is awkward..

Any help very gratefully received,

Matt



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Two, two, TWO treats in one.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
