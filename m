From: Peter Staubach <staubach@redhat.com>
Subject: Re: strange caching behavior
Date: Fri, 08 Jul 2005 14:17:48 -0400
Message-ID: <42CEC34C.6040204@redhat.com>
References: <3C7A1801D550F14B96C2EB6D2C8B989B08350CCD@seaex01.180solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DqxQS-0005zA-Kd
	for nfs@lists.sourceforge.net; Fri, 08 Jul 2005 11:18:12 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2-new.sourceforge.net with esmtp (Exim 4.44)
	id 1DqxQS-0005Ur-7p
	for nfs@lists.sourceforge.net; Fri, 08 Jul 2005 11:18:12 -0700
To: Mark Steele <mark@zango.com>
In-Reply-To: <3C7A1801D550F14B96C2EB6D2C8B989B08350CCD@seaex01.180solutions.com>
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

Mark Steele wrote:

>I've got a quick question for you NFS gurus. I'll try to keep
>this short but it's a bit complicated to explain.
>
>I've got an NFS server which exports to about 40 other
>clients. The strangeness has occurred on both 2.4.29 and
>2.6.10.
>
>Clients are all running 2.6.11.8 (nfs utils 1.0.6)
>and are serving http requests using Apache 1.3. 
>
>The majority of requests are for php scripts, and the 
>client machines use an opcode cache which compiles the 
>scripts into shared memory and caches them using the 
>filesystem timestamp as a reference to when to update 
>the cached copy.
>
>During normal operations, I'm using about 6 mbits/sec
>of bandwidth for my nfs server (pushing out 60 mbits/sec
>to the internet). However, if I update the files on the NFS
>server, it looks like all client caching goes out the
>window and suddenly start pulling 60-80 mbits/sec from
>the nfs server (still pushing out the same quantity of
>traffic to the internet).
>
>If I shutdown my web servers, and remount them all, traffic
>drops back down to 6 mbits/sec (until the next update on
>my php scripts).
>
>Anyone have an idea on what could be causing this? (or if
>this is expected behavior)
>

It seems to me that it will depend upon how this opcode cache on the client
really works and maybe whether or not you delete the old versions of the php
scripts when you install the new ones.

When the php scripts change on the server, do the clients flush this opcode
cache and then refill the opcode cache from the current versions of the
scripts again?

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
