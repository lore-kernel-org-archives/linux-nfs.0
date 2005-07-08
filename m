From: "Mark Steele" <mark@zango.com>
Subject: RE: strange caching behavior
Date: Fri, 8 Jul 2005 13:20:55 -0700
Message-ID: <3C7A1801D550F14B96C2EB6D2C8B989B0835143B@seaex01.180solutions.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DqzIx-0003nt-2y
	for nfs@lists.sourceforge.net; Fri, 08 Jul 2005 13:18:35 -0700
Received: from smtp.180solutions.com ([206.169.156.41])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.44)
	id 1DqzIv-0003s5-Pp
	for nfs@lists.sourceforge.net; Fri, 08 Jul 2005 13:18:35 -0700
To: "Peter Staubach" <staubach@redhat.com>
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

Hi Peter,

The opcode cache is working as expected. It detects the changes
in the php scripts and recompiles the new files into memory.

Therefore it sees the change in the modification time of the files.

I am using rsync to update the files on the server from a code=20
repository.

I don't see how either of things things affect the behavior of the
NFS.

Using more caching/less bandwidth when 'freshly' mounted=20
without any file updates=20

VS.=20

Using lots of bandwidth when files are changed on the NFS server
(which is done infrequently)

Mark

-----Original Message-----
From: Peter Staubach [mailto:staubach@redhat.com]=20
Sent: July 8, 2005 2:18 PM
To: Mark Steele
Cc: nfs@lists.sourceforge.net
Subject: Re: [NFS] strange caching behavior

Mark Steele wrote:

>I've got a quick question for you NFS gurus. I'll try to keep
>this short but it's a bit complicated to explain.
>
>I've got an NFS server which exports to about 40 other
>clients. The strangeness has occurred on both 2.4.29 and
>2.6.10.
>
>Clients are all running 2.6.11.8 (nfs utils 1.0.6)
>and are serving http requests using Apache 1.3.=20
>
>The majority of requests are for php scripts, and the=20
>client machines use an opcode cache which compiles the=20
>scripts into shared memory and caches them using the=20
>filesystem timestamp as a reference to when to update=20
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

It seems to me that it will depend upon how this opcode cache on the
client
really works and maybe whether or not you delete the old versions of the
php
scripts when you install the new ones.

When the php scripts change on the server, do the clients flush this
opcode
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
