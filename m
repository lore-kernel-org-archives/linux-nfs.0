From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: jumbo frames and performance
Date: Mon, 17 Jun 2002 12:26:44 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6440EA1A6AA1D5118C6900902745938E50CFE4@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01-a.netapp.com ([198.95.226.53])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17K29V-0006QE-00
	for <nfs@lists.sourceforge.net>; Mon, 17 Jun 2002 12:27:01 -0700
To: "'Raphael Clifford'" <cliffor@rockefeller.edu>, nfs@lists.sourceforge.net
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

> Would you mind explaining the two performance points below a 
> bit further 
> and maybe putting them in the FAQ?  They look very interesting. 
> Regarding the "sync" option, why does not having it incur 
> extra costs at the server?
> 
> >It also looks like you are not using jumbo frames, which 
> >Trond has mentioned as a big performance boost for tcp in 
> >100 baseT full duplex environments.

as far as i know, jumbo frames are supported only on gigabit.

> >Also, since you're using 0.3.3 utils, I assume you are 
> >using sync exports; otherwise there are costs at the server 
> >which are hidden from the benchmark data.

if you use "sync" the server behaves like all other NFS servers
and pushes data to disk when the client asks it to.  if you
use "async" the server ignores the client, and pushes data to
disk when it feels like it.

so, if you benchmark with "async" you get artificially good
write results because the server responds "OK" to write requests
before it has really written them to disk.  "async" is not
an option you would ever use in a production environment,
naturally.

this is explained somewhere in the performance chapter, near
the end.

_______________________________________________________________

Sponsored by:
ThinkGeek at http://www.ThinkGeek.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
