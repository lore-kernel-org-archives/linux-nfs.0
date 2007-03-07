From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH] NFS: Sign Extentions with Tru64 FSIDs.
Date: Wed, 07 Mar 2007 11:29:23 -0500
Message-ID: <45EEE863.4090202@redhat.com>
References: <45EC7F0F.4090600@RedHat.com>		<1173130678.6315.7.camel@heimdal.trondhjem.org>		<45EC8FD3.4010809@redhat.com>		<1173132182.6315.27.camel@heimdal.trondhjem.org>		<45EC9837.1010504@redhat.com>	<1173186308.6393.7.camel@heimdal.trondhjem.org>	<45ED8135.2010008@RedHat.com>	<45EDE060.3020501@RedHat.com>
	<45EECE74.6070606@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	"'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>,
	Steve Dickson <SteveD@redhat.com>
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HOz1H-0006gW-JU
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 08:29:39 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HOz1F-0006wW-9B
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 08:29:38 -0800
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
> A comment...
>
> You've implemented a "negative" -- the usual convention is to 
> implement the "positive" option.   This is how Apple/*BSD do it for 
> READDIRPLUS, and it might be good to follow existing precedent.
>
> I think you should implement "rddirplus" and make it the default.  
> That way you get "norddirplus" automatically.
>
> You should also include appropriate man page changes in your patch. ;-D
>

If "rddirplus" is the option and is the default, how do you turn it off?

Actually, I am also curious why any existing precedent is interesting.
In general, none of the existing precedents have been followed in the
past...  :-)

    Thanx...

       ps

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
