From: Christian Reis <kiko@async.com.br>
Subject: Mount: permission denied
Date: Thu, 29 Aug 2002 10:57:17 -0300
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020829105717.M6099@blackjesus.async.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
To: NFS@lists.sourceforge.net
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


I've got a box that mounts a number of exported directories from a
server. The client is a 2.4.12 box, and the server is 2.4.19 with neil
and trond's full patches applied.

When the client is mounting the NFS directories, all but one of the
mounts succeed. This is a bit bizarre as the mount lines in fstab are
the same, as are the export lines:

# dist succeeds
anthem:/dist   /dist      nfs defaults,rsize=8192,wsize=8192,async   0 0
# mondo fails
anthem:/mondo   /mondo    nfs defaults,rsize=8192,wsize=8192,async   0 0

# exports; exportfs -ra has been run
/dist       *.async.com.br(no_root_squash,rw,async)
/mondo      *.async.com.br(no_root_squash,rw,async)

dude:~$ sudo mount /mondo/
mount: anthem:/mondo failed, reason given by server: Permission denied
dude:~$ sudo mount /dist/
dude:~$ 

Aug 29 10:51:41 anthem rpc.mountd: authenticated mount request from
dude.async.com.br:749 for /mondo (/mondo) 
Aug 29 10:55:20 anthem rpc.mountd: authenticated mount request from
dude.async.com.br:781 for /dist (/dist) 

It seems authentication *almost* works, but it doesn't.  Could it be
that something in /var/lib/nfs is corrupted?

Take care,
--
Christian Reis, Senior Engineer, Async Open Source, Brazil.
http://async.com.br/~kiko/ | [+55 16] 261 2331 | NMFL


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
