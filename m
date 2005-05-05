From: Filipe Brandenburger <branden@terra.com.br>
Subject: Problem related to directory caches
Date: Thu, 05 May 2005 18:08:09 -0300
Message-ID: <20050505172123.4629.BRANDEN@terra.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DTnZw-00058r-4p
	for nfs@lists.sourceforge.net; Thu, 05 May 2005 14:08:16 -0700
Received: from loncoche.terra.com.br ([200.154.55.229])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DTnZt-0006US-BT
	for nfs@lists.sourceforge.net; Thu, 05 May 2005 14:08:16 -0700
Received: from pasto.terra.com.br (pasto.terra.com.br [200.154.55.137])
	by loncoche.terra.com.br (Postfix) with ESMTP id D3630E78536
	for <nfs@lists.sourceforge.net>; Thu,  5 May 2005 18:08:09 -0300 (BRT)
To: nfs@lists.sourceforge.net
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


Hello, there.

First of all, I'd like to thank all on the list for helping with my
previous doubts, it was very helpful.

Now, I'm having a problem, and I believe it may be related to cache of
directory entries. My environment is:
- clients are Linux RH7.3 with kernel 2.4.9
- servers are EMC Celerra, NS700 and Netapp FAS740
- mount options are rw,vers=3,proto=udp,nolock,rsize=8192,wsize=8192

The behaviour I'm getting is: I'm creating files in a directory, only
creating not removing, but sometimes, one of the clients reports a
number of files that is less than one other client reported some time
ago. For example, this is what I have in logs:

May  1 05:49:00 cabue trrmfsbuilder[23479]: ... Msgs [20], Read [0], New [20], Bytes [179742]

May  1 05:49:02 lusaca trrmfsbuilder[11519]: ... Msgs [19], Read [0], New [19], Bytes [176448]

What these logs mean:
1) At 5:49:00, host cabue found 20 files on the directory
2) At 5:49:02 (two seconds later), host lusaca found only 19 files on
the same directory.

This is a NFS directory. I checked time differences, but both hosts are
running NTP (without problems) and they certainly don't have as much as
2 seconds difference, they certainly have less than 1 second difference...

Can this be caused by NFS cache of the directory entry? I know that host
lusaca probably saw this same directory some seconds before it counted
19 files, so that I believe this could be cached somehow and causing the
problem of not finding the 20 files that probably were there...

If the problem is this, how can I solve it?

I thought of two solutions, but I have some questions about it:

1) I could set flags such as "noac" or "acdirmax=0" or something like
that (what would be the right ones to force no cache for directory
entries?). But I also would like to know what other impact can I have
for doing this, I guess that probably changing this would impact other
applications as well...

2) I read about using "fcntl" with "FLOCK" to flush a file's cache on
Linux (even mounting with "nolock" this is supposed to work). Is that so?
Can I use it on a directory entry? In that case, should I fcntl the
directory itself?

Well, what do you think? Can you help me on this? Can you tell me if on
of my two options would give me data that is not subject to
inconsistency because of the cache? Can you tell me if there is a better
way to do it? Can a more recent kernel solve this kind of problem?

Thanks a lot on advance! I hope you can help!
Filipe



-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.
Get your fingers limbered up and give it your best shot. 4 great events, 4
opportunities to win big! Highest score wins.NEC IT Guy Games. Play to
win an NEC 61 plasma display. Visit http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
