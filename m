From: Pierre Ossman <drzeus-list@drzeus.cx>
Subject: Re: NFSv4 needs restart (permission denied)
Date: Mon, 06 Dec 2004 19:23:46 +0100
Message-ID: <41B4A3B2.5050202@drzeus.cx>
References: <41B0A7C0.1020209@drzeus.cx> <20041206151836.GD20864@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CbNWi-0003Qv-SB
	for nfs@lists.sourceforge.net; Mon, 06 Dec 2004 10:24:00 -0800
Received: from a26.t1.student.liu.se
	([130.236.221.26] helo=mail.drzeus.cx ident=daemon)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CbNWg-0005HP-JX
	for nfs@lists.sourceforge.net; Mon, 06 Dec 2004 10:23:59 -0800
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20041206151836.GD20864@fieldses.org>
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

J. Bruce Fields wrote:

>On Fri, Dec 03, 2004 at 06:52:00PM +0100, Pierre Ossman wrote:
>  
>
>>Whenever I reboot my file server one of my clients has trouble accessing
>>the exports. I just get permission denied. However, when I restart nfsd
>>it works fine. The other clients have no problems mounting.
>>    
>>
>
>NFSv4's server reboot recovery isn't really working yet--a Linux client
>should be able to survive a non-Linux server reboot, but if a Linux
>server reboots the clients its client will probably be lost.  The
>missing piece is some code to store state about connected clients in
>stable storage, which we're working on right now.
>
>  
>
The problems isn't clients reconnecting, it's new mounts after the 
server has rebooted.



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
