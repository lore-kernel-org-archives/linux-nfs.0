From: Neil Brown <neilb@suse.de>
Subject: Re: nfs-utils patch for mount-reserved-port
Date: Tue, 13 Mar 2007 15:02:22 +1100
Message-ID: <17910.8782.28060.148247@notabene.brown>
References: <EXNANE01XsNQptgFrYI000000b1@exnane01.hq.netapp.com>
	<EXNANE01CIqtQvAauNj000000b2@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HQyDY-00006d-JW
	for nfs@lists.sourceforge.net; Mon, 12 Mar 2007 21:02:32 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HQyDY-0000lJ-D5
	for nfs@lists.sourceforge.net; Mon, 12 Mar 2007 21:02:34 -0700
In-Reply-To: message from Talpey, Thomas on Monday March 12
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

On Monday March 12, Thomas.Talpey@netapp.com wrote:
> Nobody replied yet, but on a second look, removing the compatibility
> for the fd leads directly to removing all sorts of other compatibility stuff
> being pitched too. So I think this way is best.

I agree.  
You patch had spaces instead of tabs, but that wasn't too hard to fix
up.

> 
> Yes, the second linux version check for <= 66314 technically precludes
> the fsock being still -1, but it reads better, and seems a little safer with
> the extra fsock check against the uninitialized value.

I changes 66314 to 0x1030a  :-)  and made a couple of other little
additions.

Thanks,  You can find it here
  http://neil.brown.name/git?p=nfs-utils;a=commitdiff;h=e6e19816da66cde1cc4fd062c898ce66a9b4e336

(the linux-nfs.org git-web interface seems to be malfunctioning...)


> 
> I am assuming nobody wants to patch util-linux for this kind of thing?
> (i.e. that nfs-utils will be shipped configured with --enable-mount in
> the future?)

I'm hoping to release 1.1.0 with --enable-mount as the default, but
there are still some issues pending for which patches exist but need
to be improved...

I wouldn't bother with fixing it in util-linux at this point.

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
