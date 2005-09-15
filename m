From: Peter Staubach <staubach@redhat.com>
Subject: Re: NFS problem - close to open cache consistency broken ?
Date: Thu, 15 Sep 2005 11:12:42 -0400
Message-ID: <43298F6A.9000500@redhat.com>
References: <044B81DE141D7443BCE91E8F44B3C1E288E451@exsvl02.hq.netapp.com> <20050915150824.GA24870@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: "Lever, Charles" <Charles.Lever@netapp.com>,
	Thomas Stockheim <tommi@bub-agema.de>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EFvPz-0006oE-3Z
	for nfs@lists.sourceforge.net; Thu, 15 Sep 2005 08:12:55 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EFvPx-0005UC-0b
	for nfs@lists.sourceforge.net; Thu, 15 Sep 2005 08:12:55 -0700
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20050915150824.GA24870@fieldses.org>
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

J. Bruce Fields wrote:

>On Thu, Sep 15, 2005 at 06:50:49AM -0700, Lever, Charles wrote:
>  
>
>>close-to-open is a convention, not a specification, so it's really up to
>>the client developers to implement what they think is right.
>>    
>>
>
>You can't turn off cache revalidation checks while someone else on the
>client has the file open.  Wouldn't that would make close-to-open
>useless in a lot of cases?
>

Perhaps, but close-to-open still covers cases that the normal cache
revalidation does not.  There are still windows possible with the
normal attribute cache which close-to-open handles.  Some of this
depends upon the attribute cache timeouts...

       ps


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
