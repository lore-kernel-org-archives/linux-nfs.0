From: Peter Staubach <staubach@redhat.com>
Subject: Re: Performance: NFS v3  mounting with 'noac' option
Date: Wed, 07 Mar 2007 12:55:48 -0500
Message-ID: <45EEFCA4.40000@redhat.com>
References: <253.39893.qm@web56602.mail.re3.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: AK <amithl_prem@yahoo.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HP0Rp-0002Fr-Cw
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 10:01:09 -0800
Received: from externalmx-1.sourceforge.net ([12.152.184.25])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HP0Rl-0007JJ-NF
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 10:01:07 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by externalmx-1.sourceforge.net with esmtp (Exim 4.41)
	id 1HP0Rf-0008Dj-At
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 10:00:59 -0800
In-Reply-To: <253.39893.qm@web56602.mail.re3.yahoo.com>
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

AK wrote:
> Hi All,
>
> Trying to understand what performance impact could
> result if we mount the file system with 'noac' option.
>
> We have multiple file systems begin mounted from the
> same NFS server. One of our user's application
> requires to mount the file system with 'noac' option. 
>
>   

What about this application requires that the "noac" option be used?

> We have user directories under /scratch file system,
> Now we would like to mount this file system with
> 'noac' option so that we can make one of our user
> happy. But this would afftect every user. Isn't it
> true?
>
>   

Well, you could try mounting each user's home directory individually.
The "noac" option should only apply to a specific mounted instance.

> So Now if we just decide to create a new FS
> /newScratchUserA and mount it with 'noac' option;
> WILL THIS AFFECT the other files systems mounted from
> the same server, if so how bad could it be. 
>
> Are there any other alternatives to reduce the impact
> of using this option on other mounted File systems.

One of the impacts of using the "noac" option is much more network
traffic and it will be composed of small packets.  If the server is
busy handling all of the additional GETATTR requests, then it won't
be handling other requests.  The client will also be a bit busier
with generating the additional requests, instead of just doing what
might be considered more useful work.

So, there should be no direct impact to other mounted file systems.
However, there may be indirect impacts.

       ps

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
