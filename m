From: Neil Brown <neilb@suse.de>
Subject: Re: Portmap - was Re: Does mountd/statd really need to
	listen	on a privileged port??
Date: Tue, 24 Apr 2007 17:24:14 +1000
Message-ID: <17965.45214.71167.310005@notabene.brown>
References: <17958.48121.280256.493824@notabene.brown>
	<462CB496.6000308@RedHat.com>
	<17965.15503.703515.820793@notabene.brown>
	<200704240843.10681.olaf.kirch@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, Steve Dickson <SteveD@redhat.com>,
	Matthias Koenig <mkoenig@novell.com>, nfs@lists.sourceforge.net,
	Javier =?iso-8859-1?q?Fern=E1ndez-Sanguino_Pe=F1a?= <jfs@computer.org>,
	anibal@debian.org
To: Olaf Kirch <olaf.kirch@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HgFO4-0000xm-W3
	for nfs@lists.sourceforge.net; Tue, 24 Apr 2007 00:24:33 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HgFO7-0003Qc-3E
	for nfs@lists.sourceforge.net; Tue, 24 Apr 2007 00:24:35 -0700
In-Reply-To: message from Olaf Kirch on Tuesday April 24
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

On Tuesday April 24, olaf.kirch@oracle.com wrote:
> On Tuesday 24 April 2007 01:09, Neil Brown wrote:
> > It would be nice if the libritpc version of bindrecvport could be
> > configured to avoid some list of ports, whether from /etc/services or
> > from elsewhere.
> 
> BTW, I wouldn't use /etc/services as the blacklist for bindresvport.
> The range of available privileged ports is rather tight already. If
> you exclude everything found in /etc/services, you're down to
> 249 ports in the 512-1024 range (for TCP and UDP, each). This
> will not please the 10,000 mounts crowd at Prominent CPU Vendor :)
> I really think you want to go with a separate blacklist file.

Certainly supporting a blacklist file and preferring it to
/etc/services would make sense.  Using /etc/services in the absence of
a blacklist should be safe enough.

I wonder if these is something more substantial that can be done to
avoid the problems though.

I'm aware to two problems:
 1/ ports that are held open for a long time (e.g. the port a server
    listens on, or a port that is opened once and used occasionally
    for sending messages, such as the port statd uses to talk to
    lockd).  These can conflict with servers which wish to bind to
    assigned port numbers.  We can only address this with a 
    black-list.

 2/ tcp sockets that linger in CLOSE_WAIT thus preventing other
    sockets from binding to the same address.  This prevents
    privilege ports being used at a high rate.
    Using UDP avoid this problem but is not always acceptable.
    I wonder if we could make more use of SO_REUSEADDR in
    bindresvport.  This would require handling an EADDRINUSE from
    connect, incase we are connecting to the same host as the last
    time the port was used, but if it is all in the libritpc library,
    that might be quite manageable.  Doing that should reduce the
    pressure on privileged ports.

NeilBrown


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
