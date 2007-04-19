From: Neil Brown <neilb@suse.de>
Subject: Re: Does mountd/statd really need to listen on a privileged
	port??
Date: Thu, 19 Apr 2007 10:46:49 +1000
Message-ID: <17958.48121.280256.493824@notabene.brown>
References: <17950.44333.118970.276558@notabene.brown>
	<4623BCD9.3090501@RedHat.com>
	<200704171208.51797.olaf.kirch@oracle.com>
	<17957.50539.958277.446719@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Matthias Koenig <mkoenig@novell.com>,
	Steve Dickson <SteveD@redhat.com>, jfs@computer.org,
	anibal@debian.org
To: Olaf Kirch <olaf.kirch@oracle.com>, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HeKo1-0005lN-Tp
	for nfs@lists.sourceforge.net; Wed, 18 Apr 2007 17:47:26 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HeKo4-0004FG-1M
	for nfs@lists.sourceforge.net; Wed, 18 Apr 2007 17:47:28 -0700
In-Reply-To: message from Neil Brown on Wednesday April 18
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

On Wednesday April 18, neilb@suse.de wrote:
> On Tuesday April 17, olaf.kirch@oracle.com wrote:
> > 
> > I think portmap let's joe doe replace registrations for non-privileged
> > ports. Joe Doe can't do that if the port is < 1024.
> 
> What... really?  
> 
> [[Goes to read portmap source code]]
> Yuck!  From pmap_check.c:
> 
> 
> #define reserved_port(p) (IPPORT_RESERVED/2 < (p) && (p) < IPPORT_RESERVED)
> 
> #define unreserved_port(p) (IPPORT_RESERVED <= (p) && (p) != NFS_PORT)
> 
> #define	legal_port(a,p) \
>   (reserved_port(ntohs((a)->sin_port)) || unreserved_port(p))
> 
> and elsewhere (un)registrations are only allowed if legal_port
> returns true for the source-address, port-number values.
> 
> So Joe Doe can unregister any port >= 1024 other than 2049.  How
> gross!
> That fact that 2049 has to be an exception should show that the whole
> idea is wrong.  It should record whether a registration was made with
> a privilege port and if it was, the unregistration must come from a
> privilege port too... but no.
> 
> I guess I'll put back the code to bind to privileges ports by default.
> But I'll avoid using ports listed in /etc/services.

But that doesn't help with lockd, does it?
Lockd registers a non-priv port, and fixing that is not trivial.
We really should be fixing portmap.

Portmap appeared to be a 10 year old program that each distro
maintains their own copy of...

What would people think if I added it to the nfs-utils release and
made some improvements?  Would that get into distros in parallel with
nfs-utils?


NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
