From: Alexander Bergolth <leo@strike.wu-wien.ac.at>
Subject: Re: problems using devices via nfsvers3 with 2.6.6. and 2.6.7
Date: Wed, 07 Jul 2004 09:49:48 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40EBAB1C.8010403@strike.wu-wien.ac.at>
References: <40EAF250.2080202@strike.wu-wien.ac.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bi7Bk-0008Lv-5r
	for nfs@lists.sourceforge.net; Wed, 07 Jul 2004 00:49:56 -0700
Received: from strike.wu-wien.ac.at ([137.208.8.200])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1Bi7Bj-000449-OW
	for nfs@lists.sourceforge.net; Wed, 07 Jul 2004 00:49:56 -0700
Received: from localhost (localhost.localdomain [127.0.0.1])
	by strike.wu-wien.ac.at (Postfix) with ESMTP id 93D7520011F
	for <nfs@lists.sourceforge.net>; Wed,  7 Jul 2004 09:49:50 +0200 (CEST)
To: nfs@lists.sourceforge.net
In-Reply-To: <40EAF250.2080202@strike.wu-wien.ac.at>
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

On 07/06/2004 08:41 PM, Alexander Bergolth wrote:
> I'm getting "permission denied" errors when trying to access devices 
> from a 2.6 client that are mounted via nfsvers3 and exported read-only 
> by the server. Using nfsvers2 or a 2.4 kernel doesn't show this error.

Some additional notes:
Writing to /mnt/null (which corresponds to /dev/null) only produces an 
error if the filesystem is exported read-only by the server. If the 
server exports it read-write, writing to the device works as expected, 
even if it is mounted read-only by the client.

--leo
-- 
-------------------------------------------------------
Alexander (Leo) Bergolth          leo@leo.wu-wien.ac.at
WU-Wien - Zentrum fuer Informatikdienste - Projektbuero


-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
