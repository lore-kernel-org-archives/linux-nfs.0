From: "Randy Paries" <paries@knology.net>
Subject: RE: debugging help
Date: Mon, 3 May 2004 16:24:16 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1BKkv5-0003FD-9Y@sc8-sf-mx1.sourceforge.net>
References: <20040503210628.GC4469@oaxaca.jah.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BKkva-0005sa-Ow
	for nfs@lists.sourceforge.net; Mon, 03 May 2004 14:24:42 -0700
Received: from smtp.knology.net ([24.214.63.101])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.30)
	id 1BKkv5-0003FD-9Y
	for nfs@lists.sourceforge.net; Mon, 03 May 2004 14:24:11 -0700
To: <nfs@lists.sourceforge.net>
In-Reply-To: <20040503210628.GC4469@oaxaca.jah.net>
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

Thank you for the suggestion, I am going to try that

I was also wondering if there was something I need to look at as far as
tuning so I do not need to keep increasing the timeouts?

Thanks 

-----Original Message-----
From: Peter Hicks [mailto:petong@jah.net] 
Sent: Monday, May 03, 2004 4:06 PM
To: Randy Paries
Subject: Re: [NFS] debugging help

On Mon, May 03, 2004 at 03:54:26PM -0500, Randy Paries wrote:
>Hello
> 
>I have two boxes. One is the NFS server and one is the client.
> 
>They are very busy web servers. 
> 
>i keep getting these errors on my console and in my message file May  3 
>12:44:11 krusty kernel: nfs: server local.flanders not responding, 
>still trying May  3 12:44:15 krusty kernel: nfs: server local.flanders 
>OK
>
>I am looking for suggestions on how to debug these.

I used to get those errors, but I increased the timeout values in my mount
options:

fileserver:/home/users      /mnt/server1   nfs
rw,intr,rsize=4096,wsize=4096,retrans=10,timeo=20 	0       0


See if that works for you.





-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
