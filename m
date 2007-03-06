From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] NFS: Sign Extentions with Tru64 FSIDs.
Date: Tue, 06 Mar 2007 09:56:53 -0500
Message-ID: <45ED8135.2010008@RedHat.com>
References: <45EC7F0F.4090600@RedHat.com>	
	<1173130678.6315.7.camel@heimdal.trondhjem.org>	
	<45EC8FD3.4010809@redhat.com>	
	<1173132182.6315.27.camel@heimdal.trondhjem.org>	
	<45EC9837.1010504@redhat.com>
	<1173186308.6393.7.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Peter Staubach <staubach@redhat.com>,
	"'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HOb61-0005pP-Vw
	for nfs@lists.sourceforge.net; Tue, 06 Mar 2007 06:56:58 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HOb62-0007E4-RB
	for nfs@lists.sourceforge.net; Tue, 06 Mar 2007 06:57:00 -0800
In-Reply-To: <1173186308.6393.7.camel@heimdal.trondhjem.org>
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



Trond Myklebust wrote:
> On Mon, 2007-03-05 at 17:22 -0500, Peter Staubach wrote:
>> Or we could just punt and document that READDIRPLUS must be disabled
>> on all Tru64 NFS servers if this problem is seen.
> 
> That would also be an option.
Assuming there is a way to turn off READDIRPLUS  on the
server side... I'll look into it... Or are you suggesting
that we have a mount option to turn off READDIRPLUS on the
client side? (Note: I believe other implementations have
this mount option if that means anything)....

steved.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
