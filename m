From: Brian Pawlowski <beepy@netapp.com>
Subject: Re: Re: network storage solutions
Date: Thu, 15 May 2003 23:07:07 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200305160607.h4G677M29359@orbit-fe.eng.netapp.com>
References: <200305151819.h4FIJBq19624@orbit-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: jeffrey.b.layton@lmco.com, beowulf@beowulf.org,
   landman@scalableinformatics.com, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19GYNJ-0004ke-00
	for <nfs@lists.sourceforge.net>; Thu, 15 May 2003 23:07:25 -0700
In-Reply-To: <200305151819.h4FIJBq19624@orbit-fe.eng.netapp.com> from Brian Pawlowski at "May 15, 3 11:19:11 am"
To: beepy@netapp.com (Brian Pawlowski)
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

> People use soft mounts for (1) improved performance (you can juice
> up cheap servers by caching data), or (2) prevent hung clients
> in face of unreliable networks and servers (when client is accessing
> many NFS servers).

Skip (1) - that is (a)sync on server (not soft mounts).  I should think before
I type:-)

So, Windows CIFS has dramatic "soft mount" like behaviour (some
popup like "Delayed writes lost" on session disconnect).  Always
a pain - makes me want hard mount NFS behaviour.


-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
