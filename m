From: Neil Brown <neilb@suse.de>
Subject: Re: Does mountd/statd really need to listen on a
	privileged	port??
Date: Mon, 16 Apr 2007 11:03:44 +1000
Message-ID: <17954.52080.186970.822070@notabene.brown>
References: <17950.44333.118970.276558@notabene.brown>
	<1176422715.6705.13.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HdFdR-0004rZ-AQ
	for nfs@lists.sourceforge.net; Sun, 15 Apr 2007 18:04:01 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HdFdS-00007v-Fl
	for nfs@lists.sourceforge.net; Sun, 15 Apr 2007 18:04:03 -0700
In-Reply-To: message from Trond Myklebust on Thursday April 12
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thursday April 12, trond.myklebust@fys.uio.no wrote:
> 
> I usually set statd to '--port 4047 --outgoing-port 4048' and mountd to
> '--port 4046'. This more or less mirrors what is apparently the default
> setup on NetApp filers (except the --outgoing-port bit) and has worked
> pretty well for me.

That surprises me...

The socket that statd binds to '--outgoing-port' is used both for
sending SM_NOTIFY requests to peer, and to pass incoming SM_NOTIFY
requests to the kernel.  And the kernel rejects those incoming
SM_NOTIFY requests if they are from non-privileged ports.

So I suspect that configuration will not handle the restart of a peer
properly. 

Which raises the question of SM_NOTIFY and privileged ports.

Does any statd require incoming SM_NOTIFY to be from a privileged
port, and from the machine given in mon_name??

Currently linux statd does not, though statd and sm-notify choose a
privilege port for outgoing messages by default.

I am tempted to require a privileged port (so that random people cannot
successfully ask my lockd to forget all locks from some innocent
client), but that would break configurations like yours (even more
than they are broken already) and might not work with non-linux
machines if they don't use a priv port...

Thoughts?

For now I have changed statd/mountd/rquotad to listen on a non-priv
port by default, and statd/sm-notify choose privileged ports that are
not registered in /etc/services when possible.

Thanks,
NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
