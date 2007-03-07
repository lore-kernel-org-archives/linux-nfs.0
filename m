From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] NFS: Sign Extentions with Tru64 FSIDs.
Date: Wed, 07 Mar 2007 14:20:47 -0500
Message-ID: <45EF108F.4050608@RedHat.com>
References: <45EC7F0F.4090600@RedHat.com>		<1173130678.6315.7.camel@heimdal.trondhjem.org>		<45EC8FD3.4010809@redhat.com>		<1173132182.6315.27.camel@heimdal.trondhjem.org>		<45EC9837.1010504@redhat.com>	<1173186308.6393.7.camel@heimdal.trondhjem.org>	<45ED8135.2010008@RedHat.com>
	<45EDE060.3020501@RedHat.com> <45EECE74.6070606@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	"'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HP26B-0004xW-8F
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 11:47:01 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HP269-0000NE-VJ
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 11:46:57 -0800
In-Reply-To: <45EECE74.6070606@oracle.com>
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



Chuck Lever wrote:
> You've implemented a "negative" -- the usual convention is to implement 
> the "positive" option.   This is how Apple/*BSD do it for READDIRPLUS, 
> and it might be good to follow existing precedent.
True... but I pattern it after the our 'noacl' option....
so I am following the existing precedent (using the same characters as 
Apple) but only to a point... ;-) How much precedent can one take! :-D

> 
> I think you should implement "rddirplus" and make it the default.  That 
> way you get "norddirplus" automatically.
Take a closer look... -o rdirplus is the default... and -o nordirplus
is not...
> 
> You should also include appropriate man page changes in your patch. ;-D
Maybe the man page can be worded better...

steved.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
