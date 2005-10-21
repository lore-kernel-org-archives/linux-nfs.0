From: Sean Dogar <sean@catfeeder.net>
Subject: Re: How to find what to make "df -jk" hang (redhat)
Date: Fri, 21 Oct 2005 15:31:11 -0700
Message-ID: <43596C2F.5020306@catfeeder.net>
References: <20051021220205.410.qmail@web52402.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ET5QH-0006Rx-K8
	for nfs@lists.sourceforge.net; Fri, 21 Oct 2005 15:31:37 -0700
Received: from [67.99.103.10] (helo=pigeon.catfeeder.net)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1ET5QG-0002zw-F4
	for nfs@lists.sourceforge.net; Fri, 21 Oct 2005 15:31:37 -0700
To: Jun Zhang <nugulus@yahoo.com>
In-Reply-To: <20051021220205.410.qmail@web52402.mail.yahoo.com>
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

Jun Zhang wrote:

>  
> Many a time when I type df -k, the prompt will not come back. Went to 
> another session, I found the df process is not killable. I then 
> checked each piece in /etc/fstab, each piece is fine (mounted and 
> accessible).
> Can somebosy give a clue?
>  
> Jun
>
> ------------------------------------------------------------------------
> Yahoo! FareChase - Search multiple travel sites in one click. 
> <http://us.lrd.yahoo.com/_ylc=X3oDMTFqODRtdXQ4BF9TAzMyOTc1MDIEX3MDOTY2ODgxNjkEcG9zAzEEc2VjA21haWwtZm9vdGVyBHNsawNmYw--/SIG=110oav78o/**http%3a//farechase.yahoo.com/> 


What about mounted filesystem that aren't in /etc/fstab?  There may be 
manually mounted NFS filesystems that are hung.  Do a "mount" with no 
arguments and take a look. 

-Sean


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
