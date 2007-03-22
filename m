From: Amit Gud <gud@ksu.edu>
Subject: Re: [PATCH 01/11] nfs-utils: mount: non-nfs mount options
Date: Thu, 22 Mar 2007 16:23:34 -0500
Message-ID: <4602F3D6.4090803@ksu.edu>
References: <45E2C1C1.9050302@RedHat.com>	<17891.51711.148463.251589@notabene.brown>	<45FAB6DC.6060706@RedHat.com>
	<17917.52788.9258.451246@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>,
	Steve Dickson <SteveD@redhat.com>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HUV19-0006c1-Cy
	for nfs@lists.sourceforge.net; Thu, 22 Mar 2007 14:40:19 -0700
Received: from smtp3.cc.ksu.edu ([129.130.7.17])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HUV18-0001Lk-4Q
	for nfs@lists.sourceforge.net; Thu, 22 Mar 2007 14:40:21 -0700
In-Reply-To: <17917.52788.9258.451246@notabene.brown>
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

Neil Brown wrote:
> On Friday March 16, SteveD@redhat.com wrote:
>>> and possible some other things that I didn't notice.  As this is a
>>> setuid program, I really want to be able to review changes in
>>> isolation please.
>> Ok... I broke the original patch up into 3 separate ones.
>> Pleas see attachments...
> 
> Thanks.  I've applied the last.
> I'd really like to understand the ln/cp issue before applying.  And
> I'm not quite ready to turn on setuid yet.  Maybe when I do that,
> testing will show something.
> 

I was not able to retain the setuid bit with ln, so I copied the files 
over with -p option.


AG
-- 
May the source be with you.
http://www.cis.ksu.edu/~gud


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
