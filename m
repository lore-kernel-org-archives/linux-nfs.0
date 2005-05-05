From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: Problem related to directory caches
Date: Thu, 05 May 2005 19:48:38 -0400
Message-ID: <1115336918.6532.22.camel@lade.trondhjem.org>
References: <20050505172123.4629.BRANDEN@terra.com.br>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-list1-b.sourceforge.net ([10.3.1.7] helo=sc8-sf-list1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DTq8W-0008KW-EU
	for nfs@lists.sourceforge.net; Thu, 05 May 2005 16:52:08 -0700
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 4.30)
	id 1DTq5F-0002ki-KH
	for nfs@lists.sourceforge.net; Thu, 05 May 2005 16:48:45 -0700
Received: from mx1.netapp.com ([216.240.18.38])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DTq5F-0002Md-AL
	for nfs@lists.sourceforge.net; Thu, 05 May 2005 16:48:45 -0700
To: Filipe Brandenburger <branden@terra.com.br>
In-Reply-To: <20050505172123.4629.BRANDEN@terra.com.br>
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

to den 05.05.2005 Klokka 18:08 (-0300) skreiv Filipe Brandenburger: 

> I thought of two solutions, but I have some questions about it:
> 
> 1) I could set flags such as "noac" or "acdirmax=0" or something like
> that (what would be the right ones to force no cache for directory
> entries?). But I also would like to know what other impact can I have
> for doing this, I guess that probably changing this would impact other
> applications as well...

It would mainly impact the server since it will be bombarded with
GETATTR calls every time you do something in a directory.

> 2) I read about using "fcntl" with "FLOCK" to flush a file's cache on
> Linux (even mounting with "nolock" this is supposed to work). Is that so?
> Can I use it on a directory entry? In that case, should I fcntl the
> directory itself?

You would have to set a read lock, since you cannot open a directory for
writing. That would normally suffice to flush the readdir cache, though.

> Well, what do you think? Can you help me on this? Can you tell me if on
> of my two options would give me data that is not subject to
> inconsistency because of the cache? Can you tell me if there is a better
> way to do it? Can a more recent kernel solve this kind of problem?

No. This will not suffice to ensure consistency.

Even on a single client, 2 threads that both call readdir() and then
print out the result can race. The thread that called readdir() first
can get preemptively scheduled before it prints the result, the printing
may be buffered (as I believe is the case for syslogd), etc...
The only way to ensure that they don't race is to use a mutex or some
other form of lock to ensure that the threads synchronise the operation
readdir()+printf()+flush().

The same sort of thing applies when you are comparing the output from
two different processes running on different NFS clients: you would need
some form of exclusive lock in order to synchronise the two processes.
Most of the time, it is not worth the trouble.

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by Oracle Space Sweepstakes
Want to be the first software developer in space?
Enter now for the Oracle Space Sweepstakes!
http://ads.osdn.com/?ad_id=7393&alloc_id=16281&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
