From: Kapeller Rene PSI <rene.kapeller@psi.ch>
Subject: take away nfs write permissions instantly
Date: Thu, 20 Jun 2002 12:39:59 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3D11B0FF.8030008@psi.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from psi11.psi.ch ([129.129.190.111])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17KzMC-00040H-00
	for <nfs@lists.sourceforge.net>; Thu, 20 Jun 2002 03:40:05 -0700
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

Can anyone help me on the following problem:

In order to take away nfs write permissions instantly for a previously 
mounted
nfs directory called '/data', I'm changing the export options for '/data'
on the server to 'ro', while keeping the mount on the client.

exportfs -io ro,sync,wdelay,no_root_squash nfsclient:/data

exportfs -v
/data   nfsserver(ro,wdelay,no_root_squash)

Surprisingly the client can still write to /data at this point, unless I do
umount/mount of /data.

Is this the way it's suposed to work?

Changing the nfs export options on a  SunOS 5.6 while clients have mounted
a nfs path, write permissions are instantly taken away from it.

share -F nfs -o ro,root=nfsclient /data

In both cases I used the following nfs mount options:
mount -o rw,sync,nfsvers=3,wsize=32768,rsize=32768

Thanks!
- Rene




-------------------------------------------------------
                   Bringing you mounds of caffeinated joy
                   >>>     http://thinkgeek.com/sf    <<<

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
