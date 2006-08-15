From: Peter Staubach <staubach@redhat.com>
Subject: Re: Can we flush directory data when the ctime changes?
Date: Tue, 15 Aug 2006 11:26:21 -0400
Message-ID: <44E1E79D.5080300@redhat.com>
References: <17624.15554.514216.623190@cse.unsw.edu.au>	<1155045918.5673.26.camel@localhost>
	<17633.17452.840813.593342@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GD0oM-0000Ip-5c
	for nfs@lists.sourceforge.net; Tue, 15 Aug 2006 08:26:34 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GD0oI-0004v3-9g
	for nfs@lists.sourceforge.net; Tue, 15 Aug 2006 08:26:31 -0700
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17633.17452.840813.593342@cse.unsw.edu.au>
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
> On Tuesday August 8, trond.myklebust@fys.uio.no wrote:
>   
>> On Tue, 2006-08-08 at 17:26 +1000, Neil Brown wrote:
>>     
>>> The GETATTR call that the client makes to validate the cache reports
>>> that the mtime hasn't change, *but the ctime has*.
>>>       
>> Growl! If the directory contents change, then the mtime should too. Page
>> 22 of RFC1813:
>>
>>         Mtime is the time when the file data was last modified.  Ctime
>>         is the time when the attributes of the file were last changed.
>>
>> Directory cookies are not file or directory attributes!
>>
>> In addition, NFSv3 has the cookie verifier mechanism for the server to
>> specifically inform the client that the cookies are invalid.
>>     
>
> What would you expect the user experience to be if the server returned 
> NFS3ERR_BAD_COOKIE ?
> I cannot really tell from the nfs client code, but I would guess that
> the only option would be to start again from the beginning of the
> directory, and that would lead to duplicate entries being returned,
> which is exactly the problem are seeing (though the server doesn't
> return BAD_COOKIE, it just starts again from the beginning).
>
>   

The only thing that the client can do is return an error, perhaps something
like EIO.  The real recovery needs to happen in the application, but there
isn't a way to convey the correct information to the application so that it
could do the recovery.

As was noted, transparently starting again at the beginning of the 
directory,
whether in the kernel or not, can lead to bad things happening.

In retrospect, NFS3ERR_BAD_COOKIE wasn't such a good idea.  There just
isn't enough infrastructure in the rest of the system to correctly
support the semantic that it represents.

>> IOW: this really needs to be fixed on the _server_. I'm not happy taking
>> new patches that may cause the client GETATTR calls to skyrocket again.
>>
>>     
>
> I certainly have a lot of sympathy for this position.

I would agree as well.  I think that represents a constraint on the file
systems which can be used on the server.  Although it is not a huge issue,
it sure would be nice to have it fixed.  Perhaps we need to construct the
infrastructure required in order to be able to detect and recover from
directory cookies which change mid-stream.

    Thanx...

       ps

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
