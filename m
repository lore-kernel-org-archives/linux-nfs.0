From: jehan procaccia <jehan.procaccia@int-evry.fr>
Subject: Re: async vs. sync
Date: Mon, 22 Nov 2004 23:06:13 +0100
Message-ID: <41A262D5.4090402@int-evry.fr>
References: <482A3FA0050D21419C269D13989C61130435EBD5@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CWMKK-0007Jz-PJ
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 14:06:28 -0800
Received: from smtp2.int-evry.fr ([157.159.10.45])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CWMK9-0008PY-N5
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 14:06:28 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C61130435EBD5@lavender-fe.eng.netapp.com>
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

Lever, Charles wrote:

>>[root@arvouin tmp]# mount cobra3:/p2v5f1 -o 
>>async,wsize=32768,rsize=32768,soft /mnt/cobra3
>>    
>>
>
>um.  you're not using NFS version 3?
>
>  
>
I though it was a default !?

>not to mention "soft" mounts are also truly the spawn of satan.
>  
>
OK I remove it, and force nfs v3
$mount cobra3:/p2v5f1 -o async,wsize=32768,rsize=32768,nfsvers=3 /mnt/cobra3

It is about to take the same very long time :-(

However what stricks me is that although I asked for r&wsize of 32 K , 
looking at /proc/mounts show :
$cat /proc/mounts
cobra3:/p2v5f1 /mnt/cobra3 nfs 
rw,v3,rsize=8192,wsize=8192,hard,tcp,lock,addr=cobra3 0 0

8 K r&wsize ??? I also tried with 16K it's still shows 8K ?, howerver 
moving from soft to hard did shows up in /proc/mounts .
Again, How can we check every options of an NFS mounted filesystem on 
the client side ? (other than /proc/mountd) .

thanks .





-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
