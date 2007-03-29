From: Chris Osicki <osk@admin.swisscom-mobile.ch>
Subject: Re: fsid question
Date: Thu, 29 Mar 2007 15:54:57 +0200
Message-ID: <20070329155457.458bf8a9@slopi>
References: <46082D10.1060301@cse.yorku.ca>
	<46083474.8090906@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Jason Keltz <jas@cse.yorku.ca>
To: Wendy Cheng <wcheng@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HWv9S-00017b-4M
	for nfs@lists.sourceforge.net; Thu, 29 Mar 2007 06:58:56 -0700
Received: from outmail20.swisscom.com ([138.190.3.140] helo=mrp.swissptt.ch)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HWv91-0003Ra-VQ
	for nfs@lists.sourceforge.net; Thu, 29 Mar 2007 06:58:55 -0700
In-Reply-To: <46083474.8090906@redhat.com>
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

On Mon, 26 Mar 2007 17:00:36 -0400
Wendy Cheng <wcheng@redhat.com> wrote:

Hi

> Jason Keltz wrote:
> > Hi.
> >
> > I'm running a RedHat Enterprise 4 system.
> >
> > I have a question about the fsid option in /etc/exports that I was 
> > hoping someone might be able to help with.
> >
> > I am working with LVM under Linux.  If I export LVM volumes via NFS, the 
> > fsid is based on major/minor number.  
> This statement needs correction. An NFS fsid is not based on major/minor 
> numbers - it is is a 32 bit number that admin (root) can arbitrary 
> choose and use to uniquely identify an NFS export. More on this in the 
> following comment.

And this statement needs correction too ;-)
fsid _is_ based on major/minor number. I learned it the hard way,
seeing two filesystem swapped on NFS clients because of minor
number change after switching a cluster package to another node.

Then I read carefully fsid section in man 5 exports.

Regards,
Chris

[snip] 

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
