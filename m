From: Neil Horman <nhorman@redhat.com>
Subject: Re: Help needed
Date: Thu, 5 May 2005 09:18:04 -0400
Message-ID: <20050505131804.GD12573@hmsendeavour.rdu.redhat.com>
References: <200505041206.20407.benjamin@benjamin76.plus.com> <20050504122601.GA5439@hmsendeavour.rdu.redhat.com> <200505041335.04210.benjamin@benjamin76.plus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DTgF6-0005OU-Iw
	for nfs@lists.sourceforge.net; Thu, 05 May 2005 06:18:16 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DTgF4-0001H2-W0
	for nfs@lists.sourceforge.net; Thu, 05 May 2005 06:18:16 -0700
To: Benjamin Jeeves <benjamin@benjamin76.plus.com>
In-Reply-To: <200505041335.04210.benjamin@benjamin76.plus.com>
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

On Wed, May 04, 2005 at 01:35:04PM +0100, Benjamin Jeeves wrote:
> Hi
> 
> So what you are saying is that nfs server will not bind to one or more specify 
> interfaces which would mean that you would have to do load balancing if you 
> wanted it to work over two ethernet card YES/NO? if Yes then where is the 
> best place to start?
> 
If you want to do load balancing for your network interfaces, I suggest that you
use the bonding driver.  It aggregates physical interfaces into one big
interface, and allows you to set all sorts of load balancing policies.
HTH
Neil


> Thank you
> 
> Benjamin Jeeves
> 
> On Wednesday 04 May 2005 13:26, Neil Horman wrote:
> > On Wed, May 04, 2005 at 12:06:20PM +0100, Benjamin Jeeves wrote:
> > > Hi all
> > >
> > > This is the first time posting to this list so please understand if this
> > > quistion has been posted before.
> > >
> > > I have one server with 4 ethernet card in all running on 192.168.1.*
> > > network what i want to do is run nfs on.
> > >
> > > eth2 192.168.1.6 running nfs
> > > eth3 192.168.1.7 running nfs
> > >
> > > eth2 would export samething like this /backup then /store.
> > >
> > > eth3 would export samething like this /folder3 /folder4
> > >
> > > but at this time all I can do is make it work on all of the ethernet
> > > cards and only work on the first ethernet card eth0 for all requests.
> > >
> > > I have search gooogle and man pages but can not find anything or would I
> > > need to do load balancing for this to work?
> > >
> > > I have tryed this in the /etc/exports file:
> > > 192.168.1.6:/backup	192.168.1.12(rw,root_squash,sync)
> > > 192.168.1.6:/store	192.168.1.12(rw,root_squash,sync)
> > > 192.168.1.7:/folder3	192.168.1.14(rw,root_squash,sync)
> > > 192.168.1.7:/folder4	192.168.1.14(rw,root_squash,sync)
> > >
> > > #mount 192.168.1.6:/mad-backup /backup
> > >
> > > But when i try to mount it on the client I get a this msg
> > > mount: 192.168.1.6:/backup failed, reason given by server: Permission
> > > denied
> > >
> > > please help me?
> > >
> > > Thank you
> > >
> > > Benjamin Jeeves
> >
> > I believe that your export file is written incorrectly.  The export file
> > lists directories to export, you can't use it to specify which interfaces
> > on your server will serve those exports.  The NFS service is probably
> > reading your exports file and interpreting 192.168.1.[6|7] as part of the
> > path to export, so when you have a client try to mount 192.168.1.6:/backup,
> > it fails, because /backup isn't actually exported, 192.168.1.6:/backup is. 
> > Remove the leading ip addresses from your exports file and restart the
> > service, and your mount will likely start to work just fine.
> > Regards
> > Neil
> >
> > > -------------------------------------------------------
> > > This SF.Net email is sponsored by: NEC IT Guy Games.
> > > Get your fingers limbered up and give it your best shot. 4 great events,
> > > 4 opportunities to win big! Highest score wins.NEC IT Guy Games. Play to
> > > win an NEC 61 plasma display. Visit http://www.necitguy.com/?r=20
> > > _______________________________________________
> > > NFS maillist  -  NFS@lists.sourceforge.net
> > > https://lists.sourceforge.net/lists/listinfo/nfs
> 
> 
> -------------------------------------------------------
> This SF.Net email is sponsored by: NEC IT Guy Games.
> Get your fingers limbered up and give it your best shot. 4 great events, 4
> opportunities to win big! Highest score wins.NEC IT Guy Games. Play to
> win an NEC 61 plasma display. Visit http://www.necitguy.com/?r=20
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

-- 
/***************************************************
 *Neil Horman
 *Software Engineer
 *Red Hat, Inc.
 *nhorman@redhat.com
 *gpg keyid: 1024D / 0x92A74FA1
 *http://pgp.mit.edu
 ***************************************************/


-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.
Get your fingers limbered up and give it your best shot. 4 great events, 4
opportunities to win big! Highest score wins.NEC IT Guy Games. Play to
win an NEC 61 plasma display. Visit http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
