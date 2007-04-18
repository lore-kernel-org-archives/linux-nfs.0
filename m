From: Neil Brown <neilb@suse.de>
Subject: Re: Does mountd/statd really need to listen on a
	privileged	port??
Date: Wed, 18 Apr 2007 17:14:51 +1000
Message-ID: <17957.50539.958277.446719@notabene.brown>
References: <17950.44333.118970.276558@notabene.brown>
	<4623BCD9.3090501@RedHat.com>
	<200704171208.51797.olaf.kirch@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Steve Dickson <SteveD@redhat.com>
To: Olaf Kirch <olaf.kirch@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1He4Nm-0000u8-DE
	for nfs@lists.sourceforge.net; Wed, 18 Apr 2007 00:15:14 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1He4No-0001cv-K8
	for nfs@lists.sourceforge.net; Wed, 18 Apr 2007 00:15:16 -0700
In-Reply-To: message from Olaf Kirch on Tuesday April 17
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

On Tuesday April 17, olaf.kirch@oracle.com wrote:
> On Monday 16 April 2007 20:13, Steve Dickson wrote:
> > > But is there some reason that mountd/statd need a priv port that I
> > > haven't thought of?
> > I don't think so... since neither mountd or statd checks to see
> > if the source port is a priv port, its not clear why they should
> > listen on one...
> 
> I think portmap let's joe doe replace registrations for non-privileged
> ports. Joe Doe can't do that if the port is < 1024.

What... really?  

[[Goes to read portmap source code]]
Yuck!  From pmap_check.c:


#define reserved_port(p) (IPPORT_RESERVED/2 < (p) && (p) < IPPORT_RESERVED)

#define unreserved_port(p) (IPPORT_RESERVED <= (p) && (p) != NFS_PORT)

#define	legal_port(a,p) \
  (reserved_port(ntohs((a)->sin_port)) || unreserved_port(p))

and elsewhere (un)registrations are only allowed if legal_port
returns true for the source-address, port-number values.

So Joe Doe can unregister any port >= 1024 other than 2049.  How
gross!
That fact that 2049 has to be an exception should show that the whole
idea is wrong.  It should record whether a registration was made with
a privilege port and if it was, the unregistration must come from a
privilege port too... but no.

I guess I'll put back the code to bind to privileges ports by default.
But I'll avoid using ports listed in /etc/services.

Thanks.

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
