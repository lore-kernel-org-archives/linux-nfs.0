From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: NFS Performance with sync or async
Date: Sat, 28 May 2005 09:13:54 -0700
Message-ID: <482A3FA0050D21419C269D13989C611307CF4CC1@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dc3wo-0005nI-MP
	for nfs@lists.sourceforge.net; Sat, 28 May 2005 09:14:02 -0700
Received: from mx1.netapp.com ([216.240.18.38])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1Dc3wn-0003xA-A2
	for nfs@lists.sourceforge.net; Sat, 28 May 2005 09:14:02 -0700
To: "George Garvey" <tmwg-nfs@inxservices.com>
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

> > why did you initially decide to use "sync"?
>    Reading urgings from some of the NFS authors ...
>    Also, for a while we were using an app that had a shared data base
> base on NFS store. Async concerned me in that scenario. That has also
> ended.

generally there is no need to use the "sync" mount option unless your
application depends on single system semantics (ie as soon as a write()
system call completes, all other instances of the application must be
able to see the new data).  in most cases these days, applications are
smart enough to use "fsync" and "fflush" appropriately so that "sync"
isn't necessary.

>    But I still don't understand why the sync option caused such a
> dramatic slowdown. The actual part of the program that does the
> writing went from several minutes to three seconds. If more details
> or investigation are required to answer that question, I'd love to
> know what they are so they can be provided.

the "sync" mount option on Linux restricts the behavior of the NFS
client.

1.  like opening a file with O_SYNC, the client no longer caches writes.
it always pushes written data to the server before a write() system call
returns.  normally the client allows the write() system call to return
before it has started to commit the data to lessen the write latency
experienced by applications.

2.  unlike O_SYNC, however, the "sync" mount option also causes writes
to go over the wire in page-size chunks no matter how large the wsize
is.

3.  also unlike O_SYNC, the "sync" mount option forces all application
write requests to be sent on the wire serially (ie one NFS write at a
time) and in byte order.  the reason for this behavior is to ensure that
if a large write is interrupted, at least the first portion of the write
request is guaranteed to be on permanent storage.  this makes it easier
to detect and recover from an interrupted write.

so normally, an application can make a 1MB write request via write(2)
and the client will return control immediately to the application and
push the written data to the server in the background by sending all NFS
write requests containing "wsize" (probably 32KB) bytes, all at once,
then waiting once for the result of the writes.  with the "sync" mount
option, that 1MB write request will go to the server as 256 separate 4KB
write requests, each being sent one at a time.

if the latency of a write request is 3-4msec, the "sync" case will wait
about 1 second for that 1MB write to complete.  the normal case will
return immediately to the application with only a small latency.


-------------------------------------------------------
This SF.Net email is sponsored by Yahoo.
Introducing Yahoo! Search Developer Network - Create apps using Yahoo!
Search APIs Find out how you can build Yahoo! directly into your own
Applications - visit http://developer.yahoo.net/?fr=offad-ysdn-ostg-q22005
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
