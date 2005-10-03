From: Peter Staubach <staubach@redhat.com>
Subject: Re: userid mapping
Date: Mon, 03 Oct 2005 17:50:49 -0400
Message-ID: <4341A7B9.5060109@redhat.com>
References: <1128375383.26373.4.camel@blackmamba.kapott.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EMYD4-0006lS-An
	for nfs@lists.sourceforge.net; Mon, 03 Oct 2005 14:50:58 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EMYD4-0008Bn-6j
	for nfs@lists.sourceforge.net; Mon, 03 Oct 2005 14:50:58 -0700
To: Stefan Palme <kleiner@hora-obscura.de>
In-Reply-To: <1128375383.26373.4.camel@blackmamba.kapott.org>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Stefan Palme wrote:

>Hello list,
>
>I guess this is a FAQ, but I have not found any information that
>helped me out... I'm running a NFSv3-server and clients with linux
>kernel 2.6.X. I have the same user-names on both client and server,
>but different user-ids. Is it possible to establish a mapping between
>the client's and server's userids? 
>
>A link to an earlier discussion of this topic would be enough...
>

There has never really been a standard set for mapping the numerical
userids and groupids.  There have been several implementations which
provided such a mapping, but none ever went very far.

The usual suggestion is to set up Kerberos and use RPCSEC_GSS to
pass the authentication information.

    Thanx...

       ps


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
