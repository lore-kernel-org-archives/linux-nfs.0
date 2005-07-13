From: Peter Staubach <staubach@redhat.com>
Subject: Re: NFS Client Performance Question
Date: Wed, 13 Jul 2005 15:09:50 -0400
Message-ID: <42D566FE.3060300@redhat.com>
References: <482A3FA0050D21419C269D13989C611308539DA7@lavender-fe.eng.netapp.com> <111aefd05071311553ac3d52a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: "Lever, Charles" <Charles.Lever@netapp.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DsmdV-0001Jz-0P
	for nfs@lists.sourceforge.net; Wed, 13 Jul 2005 12:11:13 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1DsmdT-0007mu-EB
	for nfs@lists.sourceforge.net; Wed, 13 Jul 2005 12:11:12 -0700
To: penney@msu.edu
In-Reply-To: <111aefd05071311553ac3d52a@mail.gmail.com>
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

Chris Penney wrote:

>The Itanium page size is 16k (unless I'm mistaken) and the r/wsize is
>32k so can that still be it?  Or are you saying that it is because the
>size of the write is only 4k?
>

Well, it is curious that the over the wire WRITE requests are still only 4K.
The Sun server is not restricting the transfer sizes, so apparently 
something
else is.

You say that the application on the client is doing random, 4K writes to
the file?  Is the file opened with O_SYNC or anything special like that?

    Thanx...

       ps


-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
