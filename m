From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH] NFS server does not update mtime on setattr
	request
Date: Wed, 07 Jun 2006 12:56:18 -0400
Message-ID: <44870532.2010902@redhat.com>
References: <4485C3FE.5070504@redhat.com> <1149658707.27298.10.camel@localhost>
	<4486E662.5080900@redhat.com> <20060607151754.GB23954@fieldses.org>
	<4486F020.3030707@redhat.com> <20060607154258.GA22335@fieldses.org>
	<4486F5C7.60606@redhat.com> <20060607160334.GB22335@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------020506000201050800080408"
Cc: Neil Brown <neilb@suse.de>, NFS List <nfs@lists.sourceforge.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-list2-b.sourceforge.net ([10.3.1.8]
	helo=sc8-sf-list2.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fo1KU-0005SQ-E5
	for nfs@lists.sourceforge.net; Wed, 07 Jun 2006 09:56:26 -0700
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Fo1KU-0007EI-4E
	for nfs@lists.sourceforge.net; Wed, 07 Jun 2006 09:56:26 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Fo1KS-0005h9-Bd
	for nfs@lists.sourceforge.net; Wed, 07 Jun 2006 09:56:25 -0700
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20060607160334.GB22335@fieldses.org>
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

This is a multi-part message in MIME format.
--------------020506000201050800080408
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

J. Bruce Fields wrote:

>On Wed, Jun 07, 2006 at 11:50:31AM -0400, Peter Staubach wrote:
>  
>
>>The Red Hat BZ number is 193621.
>>    
>>
>
>"You are not authorized to access bug #193621", it tells me....
>
>  
>

Hmm.  That ones seems to be restricted for some reason.  I think that
this happens when we get escalated bugzillas from customers.


>>The description is that when zero length files are copied, even over
>>an existing zero length file, the mtime on the target file does not
>>change.
>>    
>>
>
>Is the server-side patch sufficient on its own?
>  
>

The server side patch isn't quite sufficient on its own.  A RHEL-4 patch
is also required for the client side.  I could construct the RHEL-4 patch
so that it alone would be sufficient to address the particular problem
that that customer is having, but that isn't the entire situation.
Non-Linux clients would still have a problem with the current upstream
Linux server.  For example, in my testing, a Solaris 10 client mounting
an FC-5 server fails.  When running the attached script, the mtime on
the file, bar, should change by about 1 minute, 3 times.

    Thanx...

       ps

--------------020506000201050800080408
Content-Type: text/plain;
 name="repo"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="repo"

#!/bin/sh

rm -f foo bar

set -x

touch foo

cp foo bar

stat --format="%n %y" foo bar

sleep 60

cp foo bar

stat --format="%n %y" foo bar

sleep 60

cp foo bar

stat --format="%n %y" foo bar

sleep 60

rm foo

touch foo

cp foo bar

stat --format="%n %y" foo bar

--------------020506000201050800080408
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--------------020506000201050800080408
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------020506000201050800080408--
