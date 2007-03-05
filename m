From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH] NFS: Sign Extentions with Tru64 FSIDs.
Date: Mon, 05 Mar 2007 17:22:47 -0500
Message-ID: <45EC9837.1010504@redhat.com>
References: <45EC7F0F.4090600@RedHat.com>	
	<1173130678.6315.7.camel@heimdal.trondhjem.org>	
	<45EC8FD3.4010809@redhat.com>
	<1173132182.6315.27.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>,
	Steve Dickson <SteveD@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HOLZz-0000wT-8o
	for nfs@lists.sourceforge.net; Mon, 05 Mar 2007 14:22:51 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HOLZz-0002lc-Vn
	for nfs@lists.sourceforge.net; Mon, 05 Mar 2007 14:22:53 -0800
In-Reply-To: <1173132182.6315.27.camel@heimdal.trondhjem.org>
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
> On Mon, 2007-03-05 at 16:46 -0500, Peter Staubach wrote:
>   
>> It is an ickey idea and the right way is to fix the Tru64 server, but
>> given that we probably can't get it fixed, this seems relatively low
>> risk.
>>     
>
> I disagree. The fact that people are using the fsid in creative ways, is
> reason enough to be cautious about quick fixes. If we really must work
> around on the client, then I'd prefer something like a mount option that
> just causes us to ignore fsid changes (i.e. fall back to the 2.4.x
> behaviour).
>
> Hacking the fsid on behalf of the server is certainly vetoed.

Well, I find it a little hard to imagine that anyone would choose
a combination of fsids which would cause this to do the wrong thing,
but okay.  It is definitely a heuristic and thus, subject to possible
failure, no matter how remote.

Perhaps the right thing to do is to revert the NFSv2/NFSv3 support
completely and not have them worry about changing fsids?  The common
practice is to use an automounting facility or static mounts to
construct namespaces for NFSv2/NFSv3 networks.  It is really only
with the advent of NFSv4 that the fsids actually become interesting
and something that the client needs to be aware of.

Or we could just punt and document that READDIRPLUS must be disabled
on all Tru64 NFS servers if this problem is seen.

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
