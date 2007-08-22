From: "Morrison, Tom" <tmorrison@empirix.com>
Subject: NFS/RPC Hangs after updating time...
Date: Wed, 22 Aug 2007 14:37:22 -0400
Message-ID: <BD261180E6D35F4D9D32F3E44FD3D90108F975FB@EMPBEDEX.empirix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-kernel@vger.kernel.org,
	"Rushton, Matt" <Mrushton@empirix.com>
To: <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1INv5k-0005Hn-UP
	for nfs@lists.sourceforge.net; Wed, 22 Aug 2007 11:38:09 -0700
Received: from empbedex1.empirix.com ([12.38.203.54])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1INv5o-0000Lw-4h
	for nfs@lists.sourceforge.net; Wed, 22 Aug 2007 11:38:13 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi, 

I've got an unusual problem with a corner case that I 
am investigating. I've tried 'googling' around to 
find if someone has discussed this before, but 
I have yet to find any discussion close to this - 
so I bring it to your collective minds...

I am working with a 2.6.11++ kernel on an embedded 
server platform that is NFS serving Linux rootfs 
for other embedded NFS Client boards.

Everything works fine when the system time on the 
server board is relatively synchronized with the real-time. 

It hangs after attempting to update the time from a 
nonsensical time (e.g.: 2 months ago) - the most significant
part of it is that it only hangs IFF it has started 
serving its NFS client boards before I attempt to 
update the time.


The most significant output (when turning on 
RPC debugging) is from:

  linux/net/sunrpc/cache.c (cache_check) - line 90:

         >> Want update, refage=1800, age=4288285

It continually loops through this method - and the cache
never gets updated...even thought with some additional
sleuthing (aka: additional debug printks - it thinks 
that there is an cache update pending).

Thanks for any ideas you have on this subject.

Sincerely,

      
         
         

Tom Morrison
Principal S/W Engineer
Empirix, Inc (www.empirix.com)
tmorrison@empirix.com
(781) 266 - 3567
 
 

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
