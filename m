From: "Jake Hammer" <hammer@clarkisland.com>
Subject: RE: NFS read ok, write ok, simultaneous R+W=TERRIBLE
Date: Thu, 5 Dec 2002 11:47:19 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <CFEAJJEGMGECBCJFLGDBCEIMCJAA.hammer@clarkisland.com>
References: <20021205192917.GA16871@hpti.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "NFS" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from cynaptic.com ([128.121.116.181])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18K1y7-0004mf-00
	for <nfs@lists.sourceforge.net>; Thu, 05 Dec 2002 11:47:31 -0800
To: "Craig Tierney" <ctierney@hpti.com>
In-Reply-To: <20021205192917.GA16871@hpti.com>
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

> Are you reading and writing the files at the same time?  Or are
> you reading
> older files, while writing newer files?

20 clients all write a unique 10GB file (20 x 10GB files), then
20 clients all read the unique 10GB file written previously (20 x 10GB
files), then
20 clients all read and write new unique 10GB files *simultaneously* (20 x
10GB files read + 20 x 10GB files written - 40 total) Note that the files
being read are the same files from the first write in step 1.

> So the second test is
> still 20 clients,
> but each client is doing a read and write (to different files)?

Correct - as above.

Thanks,

Jake





-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
