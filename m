From: Christian Robottom Reis <kiko@async.com.br>
Subject: Low filehandle count
Date: Wed, 19 Oct 2005 22:20:40 -0200
Message-ID: <20051020002040.GM30673@anthem.async.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
To: NFS@lists.sourceforge.net
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


And another question related to statistics. My full output of nfsd
statistics says the following:

rc 38 29788241 306178580
fh 132 0 0 0 0
io 3014305094 803816905
th 64 2748083 59545.498 14913.486 5959.034 0.854 3293.654 2233.022 1900.395 2000.066 0.000 6550.060
ra 128 6194885 31237 6763 8614 3505 5854 4183 1654 2498 954 7362653
net 335989730 5845 335988700 13675
rpc 335952600 3 3 0 0
proc2 18 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
proc3 22 3 193912010 1129320 23275794 71338145 211734 13622462 22313635 1699001 224056 9799 4130 2508048 166400 468958 1263946 202404 2706555 1584 1501 0 910527
proc4 2 0 0

I'm curious in particular about the fh line -- why is my filehandle cache (fh)
never getting hit? I read up earlier today about why high read cache (rc)
misses are a good sign, but I've not found anything describing how to evaluate
fh. 132 stale file handles in 19 days is okay for a server with this level of
activity, but no caching?

Take care,
--
Christian Robottom Reis | http://async.com.br/~kiko/ | [+55 16] 3376 0125


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
