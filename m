From: Christian Reis <kiko@async.com.br>
Subject: Killing lockd
Date: Thu, 28 Aug 2003 15:28:08 -0300
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030828182808.GC1166@async.com.br>
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


So today I had to restart my portmapper (bizarre fact of life) and after
restarting it and all the services running, I noticed that locking was
broken. The reason was that clients no longer could contact the lockd,
since it wasn't registered after we reran the portmapper.

Now that would be fixable if we could tell lockd to restart, or kill it
and restart it manually, but I don't know how to do it. I had to reboot
the server.

Is there a way to kill lockd, or to tell it to restart and register
again in the portmapper? I do know that something (or maybe it's
suicide) tries to wait for lockd to die upon shutting down on our
diskless network, without success. Any hints?

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
