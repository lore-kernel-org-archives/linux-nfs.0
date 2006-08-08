From: Peter Staubach <staubach@redhat.com>
Subject: Re: Can we flush directory data when the ctime changes?
Date: Tue, 08 Aug 2006 10:27:23 -0400
Message-ID: <44D89F4B.8080702@redhat.com>
References: <17624.15554.514216.623190@cse.unsw.edu.au>
	<1155045918.5673.26.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GASYU-0001mz-RI
	for nfs@lists.sourceforge.net; Tue, 08 Aug 2006 07:27:39 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GASYR-0003Yy-1M
	for nfs@lists.sourceforge.net; Tue, 08 Aug 2006 07:27:39 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1155045918.5673.26.camel@localhost>
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
> On Tue, 2006-08-08 at 17:26 +1000, Neil Brown wrote:
>   
>> Hi,
>>  We have a scenario where readdir in the linux client gets confused by 
>> responses from a Netapp fileserver.
>>
>> What happens is that a readdir collects and caches the directory.
>> Then a subsequent readdir finds the first page is still in the cache
>> but the second page is missing.
>> The nfs client uses a cookie from the first page to request subsequent
>> entries and received a list of entries starting from the beginning of
>> the directory rather than from the point that it was up to.   It seems
>> that the cookies have changed.
>>
>> The GETATTR call that the client makes to validate the cache reports
>> that the mtime hasn't change, *but the ctime has*.
>>     
>
> Growl! If the directory contents change, then the mtime should too. Page
> 22 of RFC1813:
>
>         Mtime is the time when the file data was last modified.  Ctime
>         is the time when the attributes of the file were last changed.
>
> Directory cookies are not file or directory attributes!
>
> In addition, NFSv3 has the cookie verifier mechanism for the server to
> specifically inform the client that the cookies are invalid.
>
> IOW: this really needs to be fixed on the _server_. I'm not happy taking
> new patches that may cause the client GETATTR calls to skyrocket again.

This really does seem like a bug in the NetApp server.  With a change
like this, a simple chmod(2) could cause the client to invalidate its
caches...

       ps

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
