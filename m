From: "John Roberts" <john_roberts@credence.com>
Subject: Re: async vs. sync
Date: Mon, 26 Jul 2004 16:05:19 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200407262305.i6QN5JV25086@algebra.hillsboro.credence.com>
Reply-To: John Roberts <john_roberts@credence.com>
Mime-Version: 1.0
Content-Type: TEXT/plain; charset=us-ascii
Cc: bernd-schubert@web.de, john_roberts@credence.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BpEX4-0003nU-Kw
	for nfs@lists.sourceforge.net; Mon, 26 Jul 2004 16:05:22 -0700
Received: from hifw1.credence.com ([63.127.103.172] helo=hinscp.hillsboro.credence.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1BpEX4-0002Es-9f
	for nfs@lists.sourceforge.net; Mon, 26 Jul 2004 16:05:22 -0700
To: nfs@lists.sourceforge.net
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


>At least its good to know that we are not alone. Well, I do know about the 
>performance decrease of sync-exports for a pretty long time, but I was never 
>sure if its not only a problem of our server (the previous one was a 
>PII-450).

We definitely see the same problem of sync-exports _much_ slower (4x to 7x-ish)
on our network (Dell 340 and 340 workstations with 2.2 GHz Pentium IVs).

We've switched to using async when serving up our Linux volumes.


>So I really don't think that the server performance is the problem.

I absolutely agree.  In fact, I've observed that Linux clients
are _faster_ writing to slower Solaris servers than fast ones.

On a 400 MHz Sun Ultra-5 I was using as a server was 4x _faster_
than a 1.5 GHz SunBlade 2500 system.

My observation is the faster the Solaris server, the slower
the Linux NFS client (writes only).

I don't know if the whole Linux-to-Solaris write issue
can be explained by the number of COMMIT requests.
Solaris clients only issue a COMMIT request when the
file is closed or when the client's buffer cache is
flushed by memory management operations (like pageout).

However Linux client issues one COMMIT for every 32
writes, and for a 32K block size, that's one COMMIT
for every 1 Mbyte of data.

Those extra COMMITs must affect performance, but I still
think there's something else going on.



John Roberts

john_roberts@credence.com




-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
