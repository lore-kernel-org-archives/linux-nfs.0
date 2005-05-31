From: Julius Schwartzenberg <julius@zgod.cjb.net>
Subject: Problems getting NFS over SSH to work
Date: Tue, 31 May 2005 23:45:45 +0200
Message-ID: <429CDB09.1060301@zgod.cjb.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DdEZl-0005uT-5X
	for nfs@lists.sourceforge.net; Tue, 31 May 2005 14:47:05 -0700
Received: from netlx010.civ.utwente.nl ([130.89.1.92])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DdEZj-0003Vg-DK
	for nfs@lists.sourceforge.net; Tue, 31 May 2005 14:47:05 -0700
Received: from [130.89.166.98] (middelvinger.student.utwente.nl [130.89.166.98])
          by netlx010.civ.utwente.nl (8.11.7/HKD) with ESMTP id j4VLjMf29857
          for <nfs@lists.sourceforge.net>; Tue, 31 May 2005 23:45:23 +0200
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

Hi,
I've got a server & client on a campus network on which it is easy to 
'overtake' another computer by spoofing it's MAC address. Since I would 
like to access the server easily from my workstation, I thought NFS over 
SSH would be a good solution.
The server uses Slackware 10.1, the workstation uses Slackware 10.0 with 
some updates including kernel 2.6.9.
I installed UNFS3 version 0.9.12 on the server and I followed the exact 
instructions from the NFS how-to on how to set up the tunnel over SSH. 
When I run the mount command on my client, I get the following error 
message though:
mount: RPC: Cannot receive; errno = Connection refused (translated from 
dutch)
Everything works fine when I try to do the mount on the server itself 
though, so that seems to be working.
My /etc/exports file has this:
/         localhost(rw)

rpcinfo -p gives me on the server:
    program vers proto   port
     100000    2   tcp    111  portmapper
     100000    2   udp    111  portmapper
     100003    3   udp   2049  nfs
     100003    3   tcp   2049  nfs
     100005    1   udp  32767  mountd
     100005    3   udp  32767  mountd
     100005    1   tcp  32767  mountd
     100005    3   tcp  32767  mountd

Is there any way I can see what is going on (and what might be going 
wrong) with the SSH tunnel?
Thanks in advance,
Julius


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
