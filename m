From: Lawrence Ong <lawrence.ong@netregistry.com.au>
Subject: Re: SM_UNMON again -> kernel
Date: Sun, 13 Jul 2003 14:25:57 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030713042557.GA12903@quasar.nro.au.com>
References: <20030711061615.GA1924@quasar.nro.au.com> <shsr84x768e.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.netregistry.net ([203.202.16.100] helo=roanoak.netregistry.net)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19bqb7-0002NF-00
	for <nfs@lists.sourceforge.net>; Sun, 13 Jul 2003 16:49:41 -0700
Received: from proxy.netregistry.net ([203.202.16.2] helo=quasar.nro.au.com)
	by roanoak.netregistry.net with esmtp (Exim 3.35 #1 (Debian))
	id 19bqaU-0007Se-00
	for <nfs@lists.sourceforge.net>; Mon, 14 Jul 2003 09:49:02 +1000
Received: from long by quasar.nro.au.com with local (Exim 3.36 #1 (Debian))
	id 19bqZy-0004cy-00
	for <nfs@lists.sourceforge.net>; Mon, 14 Jul 2003 09:48:30 +1000
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shsr84x768e.fsf@charged.uio.no>
Resent-Message-Id: <E19bqZy-0004cy-00@quasar.nro.au.com>
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

On Fri, Jul 11, 2003 at 11:38:57AM +02i0, Trond Myklebust wrote:
> 
> Is /etc/hosts consistent? The kernel only sends MON/UNMON requests on
> the loopback port, so this suggests that something is translating
> 127.0.0.1<->"mymachine" instead of to "localhost".

Consistent?

Well, this is what i have in /etc/hosts

127.0.0.1 localhost
10.1.1.180 mymachine

With some knowledge looking at the monitor.c code, when i changed my
/etc/hosts to:

127.0.0.1 localhost mymachine

The erroneous error disappeared.  Dont't think this should be happening
AT ALL.  The statd code section:

/* Match! */
dprintf(L_DEBUG, "UNMONITORING %s for %s",
		mon_name, my_name);

Is entered when i changed /etc/hosts to 127.0.0.1 localhost mymachine.
Then again, it's logical since my_name in statd's code is set to
127.0.0.1 automatically due to CERT CA-99.05.  Maybe it's got to be
rewritten somewhat?

Anyhow, it shows that the kernel is still continually sending out
unmonitor packets to statd at regular intervals.  What the?  Why is
this happening?

Thanks for the help.

Cheers,
Lawrence

> 
> Cheers,
>   Trond


-------------------------------------------------------
This SF.Net email sponsored by: Parasoft
Error proof Web apps, automate testing & more.
Download & eval WebKing and get a free book.
www.parasoft.com/bulletproofapps1
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
