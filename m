From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 03/12] Extend the exportfs interface to
	pass	fslocations info into the kernel.
Date: Thu, 22 Feb 2007 16:17:43 +1100
Message-ID: <17885.10103.449430.747243@notabene.brown>
References: <20070208222606.23464.71348.stgit@rock.citi.umich.edu>
	<20070208222704.23464.86120.stgit@rock.citi.umich.edu>
	<17867.49873.883604.237104@notabene.brown>
	<4d569c330702090619m1ddb8c2j5068d454f27051d4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Fredric Isaman <iisaman@citi.umich.edu>,
	nfs@lists.sourceforge.net
To: "Kevin Coffman" <kwc@citi.umich.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HK6Ln-0002us-P2
	for nfs@lists.sourceforge.net; Wed, 21 Feb 2007 21:18:40 -0800
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HK6Ll-0006kS-T8
	for nfs@lists.sourceforge.net; Wed, 21 Feb 2007 21:18:39 -0800
In-Reply-To: message from Kevin Coffman on Friday February 9
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

On Friday February 9, kwc@citi.umich.edu wrote:
> 
> > And I'm a little confused by the replicas_lookup, method_list stuff.
> > I think it is just parsing the format from /etc/exports so that it can
> > be written in the different format to the kernel.
> > It would seem more appropriate to do this when parsing the
> > /etc/exports (to /etab) file rather than every time we talk to the
> > kernel.  Is there are reason for the way it is?
> > (Just trying to make sure I understand).
> 
> I'll have to defer to Fred on this.  I think he is going to be out for a week.

I wanted to push out 1.0.11 so I had another look at this patch and
decided I was happy with it after all, so it is now in, and 1.0.11
is out there.

Thanks,
NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
