From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Problems with statd and lockd
Date: 05 Apr 2003 16:27:00 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shs7ka9c957.fsf@charged.uio.no>
References: <20030405015638.5118fbb9.philippe.gramoulle@mmania.com>
	<200304051545.43063.bernd-schubert@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Philippe =?iso-8859-1?q?Gramoull=E9?= <philippe.gramoulle@mmania.com>,
	  NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 191odN-0007gQ-00
	for <nfs@lists.sourceforge.net>; Sat, 05 Apr 2003 06:27:05 -0800
To: Bernd Schubert <bernd-schubert@web.de>
In-Reply-To: <200304051545.43063.bernd-schubert@web.de>
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

>>>>> " " == Bernd Schubert <bernd-schubert@web.de> writes:

     > we also see those messages when we use the rpc.statd from
     > debian packages. I think the debian nfs-utils packages got
     > "--enable-secure-statd" as configure option. After recompiling
     > the nfs-utils without this option and starting the new
     > rpc.statd on the clients, those messages should disappear, even
     > without restarting the nfs-server.  (I discovered this odd
     > behaviour by accident.)

--enable-secure-statd is there for a good reason. I wouldn't recommend
that anybody turn it off. In any case, if that is the problem, then
you should see a warning from 'statd' in your syslog (assuming you
have enabled 'warn' messages in syslog.conf).

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: ValueWeb: 
Dedicated Hosting for just $79/mo with 500 GB of bandwidth! 
No other company gives more support or power for your dedicated server
http://click.atdmt.com/AFF/go/sdnxxaff00300020aff/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
