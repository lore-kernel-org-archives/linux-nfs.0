From: Christian Reis <kiko@async.com.br>
Subject: nfsroot.c handling of v3 vs. nfsvers=3
Date: Sun, 26 Jan 2003 13:24:19 -0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030126132419.A25395@blackjesus.async.com.br>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


Hey there,

It seems nfsroot.c's parsing of commandline options uses the strings
'v2' and 'v3' for detecting which version should be used, and that no
parsing occurs of the nfsvers parameter. Trond has actually reminded us
of this just a while back [1].

This is at least confusing, since most docs (and nfs(5) more
importantly) indicate nfsvers=3 as the correct approach. Even worse,
nfsroot.txt says "Standard NFS options", which seems to indicate the
same ones as mount would accept.

I'd be happy to either patch nfsroot.c to have this fixed if Trond
thinks its a good idea. It would have to backwards compatible, of
course, and in the case of multiple settings, the last one parsed would
be used. Sounds okay?

If not, I'll send in a patch for nfsroot.txt at least that makes things
easier to understand.

[1] http://www.uwsg.iu.edu/hypermail/linux/kernel/0201.3/0056.html

Take care,
--
Christian Reis, Senior Engineer, Async Open Source, Brazil.
http://async.com.br/~kiko/ | [+55 16] 261 2331 | NMFL


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
