From: Neil Horman <nhorman@redhat.com>
Subject: Re: possible client stale filehandle bug?
Date: Wed, 26 Jan 2005 08:07:09 -0500
Message-ID: <41F795FD.8010007@redhat.com>
References: <20050125173945.GU12269@polop.usc.edu> <1106719587.10014.4.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Garrick Staples <garrick@usc.edu>, nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CtmtH-0004gT-Vd
	for nfs@lists.sourceforge.net; Wed, 26 Jan 2005 05:07:23 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CtmtG-0006ly-F9
	for nfs@lists.sourceforge.net; Wed, 26 Jan 2005 05:07:23 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1106719587.10014.4.camel@lade.trondhjem.org>
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

Trond Myklebust wrote:
> ty den 25.01.2005 Klokka 09:39 (-0800) skreiv Garrick Staples:
> 
>>Hi all,
>>   I have lots of storage in a large Solaris samfs environment that is NFS
>>shared to a large number of Solaris and RHEL3 clients.  Under some conditions,
>>linux apps have been getting stale filehandles during the normal course of
>>their activity.  Various file handling syscalls like read() or open() might
>>error.  Lots of renames and setattrs calls seem to trigger the problem.  
>>'ci' and 'cvs commit' are particularly good at this.
> 
> 
> ESTALE is usually a sign that someone is deleting a file on the server
> that is in use by the client. It is a sign that you are doing something
> that violates the caching rules of NFS.
> 
> 
>>It seems that the Solaris clients never report any such errors, only the Linux
>>clients.  However, watching 'snoop' on the Solaris NFS server, I see that it IS
>>returning stale file handles to both OSes, but Solaris clients seem to retry
>>the request several times; and the Linux clients immediately pass the error up
>>to the application.
>>
>>Is there some condition that the 2.4 kernel is handling incorrectly?
> 
> 
> I do not believe that Solaris redrives ESTALE on read, but they may do
> it on open(). Linux does not redrive either case. See the many
> discussions in the NFS list archives for why.
> 

Solaris does in fact retry on operations on ESTALE errors, definately on 
open, and I think on read/readdir/stat/etc. as well.  We had some 
discussion about tht here recently.


-- 
/***************************************************
  *Neil Horman
  *Software Engineer
  *Red Hat, Inc.
  *nhorman@redhat.com
  *gpg keyid: 1024D / 0x92A74FA1
  *http://pgp.mit.edu
  ***************************************************/


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
