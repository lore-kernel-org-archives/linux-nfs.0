From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH] NFS server does not update mtime on
	setattr	request
Date: Fri, 09 Jun 2006 09:10:15 -0400
Message-ID: <44897337.1090309@redhat.com>
References: <4485C3FE.5070504@redhat.com>	<1149658707.27298.10.camel@localhost>	<4486E662.5080900@redhat.com>
	<17544.50037.863862.736802@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NFS List <nfs@lists.sourceforge.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fogkr-0003XG-F3
	for nfs@lists.sourceforge.net; Fri, 09 Jun 2006 06:10:25 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Fogkq-0000xR-Om
	for nfs@lists.sourceforge.net; Fri, 09 Jun 2006 06:10:25 -0700
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17544.50037.863862.736802@cse.unsw.edu.au>
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

>On Wednesday June 7, staubach@redhat.com wrote:
>  
>
>>Neil, can we get these changes integrated, please?
>>    
>>
>
>Nope.
>The discussion has already gone on from here, so I might be covering
>old ground, but there seem to be further mentions of still needing the
>server patch, so just to be sure it is covered....
>
>My reading of SUS says that 
>  open(O_TRUNC) of an empty file does not update the modify time
>  truncate() of an empty file does update the modify time
>
>  
>

These seem backwards.

>So the server has to be able to support this distinction without being
>able to directly know what API call was made on the client.
>The patch you suggest makes it impossible to support that distinction.
>
>Possibly the server could make a distinction between when nfsd_setattr
>is called directly, and when it is called via nfsd_create{,_v3}.  I
>would be more open to a patch that makes a distinction there.  However
>I think that it would be best for the client to be explicit about what
>it is doing by setting the right attr flags.
>

Yup, agreed.  I do think that we are going to have some interoperability
problems with some existing clients in the marketplace though.  Perhaps
we can get some of those folks to look at their clients and make them a
little more explicit about what bits needs to be changed, as opposed to
assuming that the server would just do what the client expected.

    Thanx...

       ps


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
