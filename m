From: Chris Jensen <chris-nfs@drspirograph.com>
Subject: Can't force unmount nfs
Date: Sat, 5 Apr 2003 22:37:52 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200304052237.52526.chris-nfs@drspirograph.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mta07ps.bigpond.com ([144.135.25.132])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 191mph-0001Um-00
	for <nfs@lists.sourceforge.net>; Sat, 05 Apr 2003 04:31:41 -0800
Received: from morbo ([144.135.25.78]) by mta07ps.bigpond.com
          (Netscape Messaging Server 4.15 mta07ps Jul 16 2002 22:47:55)
          with SMTP id HCVESQ00.1JH for <nfs@lists.sourceforge.net>; Sat,
          5 Apr 2003 22:31:38 +1000
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi,
I have a recurring problem that when an nfs server goes down and while a 
client was reading from it. If I then try to unmount the export it fails 
saying the device is busy. This happens regardless of weather the server has 
come back up or not.
Yes,  I have closed the file that was in use, even shutdown the app that was 
using it.
 fuser -v shows nothing
I've tried umount -f too and that doesn't work.
(Which leads me to ask what is -f meant to do, if not that?)
Can anyone point out what the problem is?

Also, I was wondering about a related problem - I can't use the export even 
after the server comes back up. I was under the impression that nfs is 
stateless and that you could even continue useing a share even after sending 
an unmount request to the server.
Thanks for any help

-- 
Chris Jensen

Public Key: http://drspirograph.com/public_key/

Wait: Did you know that there's a direct correlation between the decline of
Spirograph and the rise in gang activity?  Think about it.
- Dr Spirograph (The Simpsons)



-------------------------------------------------------
This SF.net email is sponsored by: ValueWeb: 
Dedicated Hosting for just $79/mo with 500 GB of bandwidth! 
No other company gives more support or power for your dedicated server
http://click.atdmt.com/AFF/go/sdnxxaff00300020aff/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
