From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Stale File handles keep coming back
Date: Tue, 26 Apr 2005 22:27:37 +1000
Message-ID: <17006.13241.129839.558300@cse.unsw.edu.au>
References: <1114463253.2487.73.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DQPAK-0006qR-9r
	for nfs@lists.sourceforge.net; Tue, 26 Apr 2005 05:27:48 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DQPAI-00011u-PH
	for nfs@lists.sourceforge.net; Tue, 26 Apr 2005 05:27:48 -0700
To: Kris Vassallo <kris@linuxcertified.com>
In-Reply-To: message from Kris Vassallo on Monday April 25
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

On Monday April 25, kris@linuxcertified.com wrote:
> I am experiencing a problem with stale file handles, and I have not been
> able to find an answer in the archives nor has doing anything in the
> readme helped. I apologize if an answer has already been posted
> regarding an issue such as this. After many frustrating hours of
> troubleshooting I am hoping for some help. The mail is long but I am
> hoping that it answers all the questions. 

Very odd...

The output of:

  echo 2048 > /proc/sys/sunrpc/rpc_debug
  grep . /proc/net/rpc/*/content
  ls -l /proc/fs/nfsd
  cat /proc/fs/nfs/exports

might help.

Thanks,
NeilBrown


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
