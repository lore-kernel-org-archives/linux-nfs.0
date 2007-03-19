From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [Fwd: Re: [PATCH] NFS: Sign Extentions with Tru64 FSIDs.]
Date: Mon, 19 Mar 2007 11:58:14 -0400
Message-ID: <45FEB316.6000102@RedHat.com>
References: <45FAB960.5060002@RedHat.com>	
	<17917.52907.759968.967401@notabene.brown>
	<45FE8A86.9050307@RedHat.com>
	<1174316909.6461.17.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HTKFY-0000pr-O6
	for nfs@lists.sourceforge.net; Mon, 19 Mar 2007 08:58:20 -0700
Received: from mx2.redhat.com ([66.187.237.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HTKFZ-0005mF-Jm
	for nfs@lists.sourceforge.net; Mon, 19 Mar 2007 08:58:22 -0700
In-Reply-To: <1174316909.6461.17.camel@heimdal.trondhjem.org>
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
> On Mon, 2007-03-19 at 09:05 -0400, Steve Dickson wrote:
>> Neil Brown wrote:
>>> On Friday March 16, SteveD@redhat.com wrote:
>>>> Any status or hope with these patches??
>>> I have no problem with the nfs-utils patch though obviously I won't
>>> commit it until Trond indicates that he will accept the fs/nfs patch. 
>> Sounds reasonable...
>>
>> Trond, any interest in the 4 line patch that would
>> enable turning off readdirplus? The Tru64 folks would
>> definitely appreciate it.. ;-)
> 
> Fine by me, but I'm curious as to why you're not doing the same for
> NFSv4? 
Cool... In this particular case, Tru64 does not support v4 so I
didn't think it was needed...

steved.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
