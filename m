From: Paul Jakma <paulj@alphyra.ie>
Subject: stale file handles if you mix IP and domain in /etc/exports
Date: Wed, 20 Mar 2002 08:56:09 +0000 (GMT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0203200848130.3761-100000@dunlop.dub.ie.alphyra.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Received: from florence.ie.alphyra.com ([193.120.224.170])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16nbue-0003o0-00
	for <nfs@lists.sourceforge.net>; Wed, 20 Mar 2002 00:57:40 -0800
Received: from dunlop.admin.ie.alphyra.com (IDENT:oqFCdIms7cluLFjrmyAjy6YTCwDKxJuI@dunlop.admin.ie.alphyra.com [192.168.11.193])
	by florence.ie.alphyra.com (8.11.6/8.11.6) with ESMTP id g2K8u9F03114
	for <nfs@lists.sourceforge.net>; Wed, 20 Mar 2002 08:56:09 GMT
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

hi,

i have a curious problem with exports...

if you have various exports on a server, some where the client ACL is 
specified by domain (eg .foo.bar) and some where it is specified by IP 
(eg 123.45.0.0/24 or even *) then a client that mounts those volumes 
will find that either:

it can access the mounts where mountd has matched on ip but gets stale
file handle for where mountd matched on domain 

and vice versa.. (and it seems to be order related. eg mounts of the
last acl "type" that the server matched will be fine, those of the 
other will be stale).

if the client umounts the export that it can access ok, (say where 
server mountd matched IP) then it can access the mounts that were 
previously stale, etc.. etc..

basically it seems a linux nfs server can not allow clients to 
access various volumes on IP or domain on a per volume basis. the 
client must be "authenticated" using one type of match only for 
all volumes the server exports.

is this a known problem?

(happens with latest RH72 updates nfs-utils, and also the nfs-utils 
currently in rawhide, ie nfs-utils-0.3.3-2)

regards,

--paulj


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
