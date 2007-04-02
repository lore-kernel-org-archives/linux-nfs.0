From: Neil Brown <neilb@suse.de>
Subject: Re: mounting tmpfs: permission denied
Date: Tue, 3 Apr 2007 08:13:09 +1000
Message-ID: <17937.32757.49781.717099@notabene.brown>
References: <1c9889d10703301416s6c1a8b38h54d653036d9ed1cf@mail.gmail.com>
	<17936.7012.831282.944994@notabene.brown>
	<1c9889d10704020914r780feb72hd9e0199bdcc2e985@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
To: InsaneToucan <insanetoucan@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HYUm5-0007Ex-Dq
	for nfs@lists.sourceforge.net; Mon, 02 Apr 2007 15:13:17 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HYUm6-0007XT-GD
	for nfs@lists.sourceforge.net; Mon, 02 Apr 2007 15:13:19 -0700
In-Reply-To: message from InsaneToucan on Monday April 2
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

On Monday April 2, insanetoucan@gmail.com wrote:
> That worked, thanks for the help.

Great.
In nfs-utils 1.1.0 (not yet released) exportfs will say
     exportfs: Warning: /tmpfs requires fsid= for NFS export

if you try to export as tmpfs filesystem without fsid=

NeilBrown


> 
> On 4/1/07, Neil Brown <neilb@suse.de> wrote:
> >
> > On Friday March 30, insanetoucan@gmail.com wrote:
> > > Hello,
> > >
> > > $ cat /etc/exports
> > > /pu 10.1.2.0/255.255.255.0(async,no_subtree_check,rw,no_root_squash)
> > > /tmpfs 10.1.2.0/255.255.255.0(ro,no_root_squash,no_subtree_check)
> >
> > You need 'fsid=something' for /tmpfs.  As there is no device nfsd
> > cannot use the device number in the filehandle, so you need to give it
> > a number to use to identify that filesystem.
> >
> > I really should do something about getting an error message out of
> > exportfs in this case.... or at least out of mountd.
> >
> > NeilBrown










-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
