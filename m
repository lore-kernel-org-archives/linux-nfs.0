From: Neil Brown <neilb@suse.de>
Subject: Re: HEADS-UP: nearing nfs-utils 1.1.0 and statd changes.
Date: Thu, 22 Mar 2007 15:54:39 +1100
Message-ID: <17922.3087.206883.910415@notabene.brown>
References: <17914.20117.186786.830574@notabene.brown>
	<EXNANE01pH71yEXUIEA000000e2@exnane01.hq.netapp.com>
	<17917.50411.770610.290399@notabene.brown>
	<EXNANE016beUzmRf6Ci00000104@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HUFK2-0007wj-Ua
	for nfs@lists.sourceforge.net; Wed, 21 Mar 2007 21:54:46 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HUFK4-0007Rh-O5
	for nfs@lists.sourceforge.net; Wed, 21 Mar 2007 21:54:49 -0700
In-Reply-To: message from Talpey, Thomas on Monday March 19
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

On Monday March 19, Thomas.Talpey@netapp.com wrote:
> At 07:02 PM 3/18/2007, Neil Brown wrote:
> >SuSE's kstatd seems to cope without resolving mon_name.
> 
> I'd be interested in the details. It's been our observation that very few
> statd implementations work properly in all cases.

It doesn't do anything particularly clever.
By default it depends on IP address matching, so as long as you don't
have multi-homed hosts everything is easy
If you do have multi-homed hosts you need to enable host-name matching
(via a sysctl) and ensure that hostnames are used consistently.
i.e. the hostname used when you mount a filesystem must be the same as
that which sm-notify on the server will use in mon_name when sending
notify that it has reboot.

In the other direction, sm-notify on the NFS client must simply mon_name
to "uname -n" as that will be the 'caller_name' in the LOCK request.
Not to hard to set up.  You just need to make sure when you mount that
you use the name that the server gets from 'uname -a'.  Probably easy
to get wrong though, and you never know it is wrong until you reboot.

I guess that to be completely safe, a NOTIFY should be sent from every
IP that the local host has, to every IP that every peer has, with
mon_name set to the source IP address, and then again with mon_name set
to the host name, both simple and FQDN.

And when you receive a NOTIFY, you should do an DNS lookup to find the
FQDN and then all the IP addresses, and then assume a reboot for any
local state that matches any of that.

Which does seem to suggest that DNS lookup is needed on receipt of
NOTIFY, so that part cannot really go in the kernel.

I might need to think about this a bit more...

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
