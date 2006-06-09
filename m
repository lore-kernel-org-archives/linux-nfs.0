From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] NFS server does not update mtime on
	setattr	request
Date: Fri, 9 Jun 2006 10:40:21 +1000
Message-ID: <17544.50037.863862.736802@cse.unsw.edu.au>
References: <4485C3FE.5070504@redhat.com> <1149658707.27298.10.camel@localhost>
	<4486E662.5080900@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NFS List <nfs@lists.sourceforge.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FoV3a-0008QX-D7
	for nfs@lists.sourceforge.net; Thu, 08 Jun 2006 17:40:58 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1FoV3Y-0000S0-6J
	for nfs@lists.sourceforge.net; Thu, 08 Jun 2006 17:40:58 -0700
To: Peter Staubach <staubach@redhat.com>
In-Reply-To: message from Peter Staubach on Wednesday June 7
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

On Wednesday June 7, staubach@redhat.com wrote:
> 
> Neil, can we get these changes integrated, please?

Nope.
The discussion has already gone on from here, so I might be covering
old ground, but there seem to be further mentions of still needing the
server patch, so just to be sure it is covered....

My reading of SUS says that 
  open(O_TRUNC) of an empty file does not update the modify time
  truncate() of an empty file does update the modify time

So the server has to be able to support this distinction without being
able to directly know what API call was made on the client.
The patch you suggest makes it impossible to support that distinction.

Possibly the server could make a distinction between when nfsd_setattr
is called directly, and when it is called via nfsd_create{,_v3}.  I
would be more open to a patch that makes a distinction there.  However
I think that it would be best for the client to be explicit about what
it is doing by setting the right attr flags.

NeilBrown



_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
