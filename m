From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Strange delays on NFS server
Date: Fri, 13 Aug 2004 10:53:53 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <411CD601.1080308@RedHat.com>
References: <4119FB15.7010205@stams.strath.ac.uk> <411A17F2.2060203@RedHat.com> <411A448D.3080205@stams.strath.ac.uk> <20040811164135.GA11101@suse.de> <411B8987.1030609@stams.strath.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Olaf Kirch <okir@suse.de>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BvdQy-0001R8-Ug
	for nfs@lists.sourceforge.net; Fri, 13 Aug 2004 07:53:32 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1BvdQy-0007ea-H9
	for nfs@lists.sourceforge.net; Fri, 13 Aug 2004 07:53:32 -0700
To: Ian Thurlbeck <ian@stams.strath.ac.uk>
In-Reply-To: <411B8987.1030609@stams.strath.ac.uk>
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



Ian Thurlbeck wrote:

>   PID USER PRI  NI  SIZE  RSS SHARE STAT %CPU %MEM   TIME CPU COMMAND
>  6365 root  16   0  1244 1244   880 R     0.9  0.2   0:15   0 top
>   156 root  15   0     0    0     0 DW    0.0  0.0  25:45   0 kjournald
>  2021 root  15   0     0    0     0 DW    0.0  0.0  17:38   0 nfsd
>  2037 root  15   0     0    0     0 DW    0.0  0.0  17:51   0 nfsd
>  2042 root  15   0     0    0     0 DW    0.0  0.0  17:07   0 nfsd
>  2044 root  15   0     0    0     0 DW    0.0  0.0  16:44   0 nfsd
>
> And then the bdflush process joins in and the number of nfsd processes
> grows, then shrinks back, and finally they all disappear.
>
Hmm... this is kinda what I expected... nfsd is waiting on the local 
filesystem....
Would it be nice if nfsd would know how to speak aio...  but  back to 
reality.....
What happens if you double/triple (assuming you have enough memory)  the 
number nfsd
that are started? does it help or hurt? My guess is it probably will not 
make a difference
but you never know....

SteveD.


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
