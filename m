From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] NFS: Sign Extentions with Tru64 FSIDs.
Date: Wed, 07 Mar 2007 09:16:15 -0500
Message-ID: <45EEC92F.6080302@RedHat.com>
References: <45EC7F0F.4090600@RedHat.com>
	<1173130678.6315.7.camel@heimdal.trondhjem.org>
	<45EC8FD3.4010809@redhat.com>
	<1173132182.6315.27.camel@heimdal.trondhjem.org>
	<45EC9837.1010504@redhat.com>
	<1173186308.6393.7.camel@heimdal.trondhjem.org>
	<45ED8135.2010008@RedHat.com> <45EDE060.3020501@RedHat.com>
	<EXNANE01WtIIZS2TRqf00000060@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HOwwF-0000X3-Fm
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 06:16:19 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HOwwG-0002Nm-2E
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 06:16:21 -0800
In-Reply-To: <EXNANE01WtIIZS2TRqf00000060@exnane01.hq.netapp.com>
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



Talpey, Thomas wrote:
> The current code already supports disabling READDIRPLUS to
> servers that don't support it. It happens after the first bad
> response. The intentional option is a good idea for other
> reasons though, huge directories yield huge attributes.
Yes... I agree this could be useful in other applications...

> 
> One problem I see with the mount option is that it might be
> silently ignored by old mount binaries. That will confuse users
> who install a new kernel and don't update util-linux/nfs-utils.
The problem is not so much old mount binaries, since they will fail
with something similar to "Unsupported nfs mount option: nordirplus",
its using new mount binaries with old kernels. The kernels
will silently ignore the option. One could tell the option is
not set by catting /proc/mounts (since the "nordirplus" would
not exist), but I agree there is potential for confusion...

But on he other hand I didn't want to increase the mount
version from 5 to 6 since I think that whole mounting version
stuff is just rats nest.. and Two, I really didn't mounts
to start failing (due to mis-versioning) for a option that
will probably never be used... But it is trivial to increase
the version, but it just causes so many headaches I was
trying to avoid it... Right or wrong that was the reasoning...

steved.


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
