From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: nfs-utils patch for mount-reserved-port
Date: Tue, 13 Mar 2007 07:37:59 -0400
Message-ID: <EXNANE01Fsxf4yp8ARf000000ba@exnane01.hq.netapp.com>
References: <EXNANE01XsNQptgFrYI000000b1@exnane01.hq.netapp.com>
	<EXNANE01CIqtQvAauNj000000b2@exnane01.hq.netapp.com>
	<17910.8782.28060.148247@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HR5Kf-0002gH-KS
	for nfs@lists.sourceforge.net; Tue, 13 Mar 2007 04:38:23 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HR5Kh-000586-KA
	for nfs@lists.sourceforge.net; Tue, 13 Mar 2007 04:38:23 -0700
In-Reply-To: <17910.8782.28060.148247@notabene.brown>
References: <EXNANE01XsNQptgFrYI000000b1@exnane01.hq.netapp.com>
	<EXNANE01CIqtQvAauNj000000b2@exnane01.hq.netapp.com>
	<17910.8782.28060.148247@notabene.brown>
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

At 12:02 AM 3/13/2007, Neil Brown wrote:
>On Monday March 12, Thomas.Talpey@netapp.com wrote:
>> Nobody replied yet, but on a second look, removing the compatibility
>> for the fd leads directly to removing all sorts of other compatibility stuff
>> being pitched too. So I think this way is best.
>
>I agree.  
>You patch had spaces instead of tabs, but that wasn't too hard to fix
>up.

Sorry 'bout that. I blame our corporate Exchange server. :-/ It had tabs
when I hit send.

>> Yes, the second linux version check for <= 66314 technically precludes
>> the fsock being still -1, but it reads better, and seems a little safer with
>> the extra fsock check against the uninitialized value.
>
>I changes 66314 to 0x1030a  :-)  and made a couple of other little
>additions.

That 66314 was already there of course, I just added the fsock test.

New version looks great. Looking forward to --enable-mount, if any
work needed for that just holler.

Tom.

>
>Thanks,  You can find it here
>  
>http://neil.brown.name/git?p=nfs-utils;a=commitdiff;h=e6e19816da66cde1cc4fd062c898ce66a9b4e336
>
>(the linux-nfs.org git-web interface seems to be malfunctioning...)
>
>
>> 
>> I am assuming nobody wants to patch util-linux for this kind of thing?
>> (i.e. that nfs-utils will be shipped configured with --enable-mount in
>> the future?)
>
>I'm hoping to release 1.1.0 with --enable-mount as the default, but
>there are still some issues pending for which patches exist but need
>to be improved...
>
>I wouldn't bother with fixing it in util-linux at this point.
>
>NeilBrown


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
