From: Peter Staubach <staubach@redhat.com>
Subject: Re: Minor problem in nfsv3 write
Date: Tue, 20 Sep 2005 08:25:43 -0400
Message-ID: <432FFFC7.7010803@redhat.com>
References: <20050920011046.23A07F4@dead.void.org> <20050920012525.GA26729@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Steven <steven@void.org>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EHhIu-0002eh-CP
	for nfs@lists.sourceforge.net; Tue, 20 Sep 2005 05:32:56 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EHhIt-0001Nt-46
	for nfs@lists.sourceforge.net; Tue, 20 Sep 2005 05:32:56 -0700
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20050920012525.GA26729@fieldses.org>
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

>On Mon, Sep 19, 2005 at 06:10:46PM -0700, Steven wrote:
>  
>
>>There is a minor bug in the way writes are handled in nfs3.  If the
>>client requests a write for more than 32k of data the server will only
>>write 32k but report that it wrote the whole amount.
>>    
>>
>
>Our server also reports 32k as the maximum write size.  So the bug is on
>the client side here, isn't it?
>

This would be a bug in the client, but if the server is going to attempt
to write some of the data anyway, then it should correctly report the
number of bytes written.  Otherwise, the server should reject the entire
request.

    Thanx...

       ps


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
