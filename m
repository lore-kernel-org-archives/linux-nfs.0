From: Steve Dickson <steved@redhat.com>
Subject: Re: How to find what to make "df -jk" hang (redhat)
Date: Sat, 22 Oct 2005 09:58:05 -0400
Message-ID: <435A456D.8080601@redhat.com>
References: <20051021220205.410.qmail@web52402.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ETJt7-0008Tl-P7
	for nfs@lists.sourceforge.net; Sat, 22 Oct 2005 06:58:21 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1ETJt6-0004bm-ME
	for nfs@lists.sourceforge.net; Sat, 22 Oct 2005 06:58:22 -0700
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

Is autofs in the picture? which kernel and nfs-utils versions are you 
running also
who is the server? Is there any errors being logged on either the client 
or server?
Finally, a ethereal trace (i.e. tethereal -w /tmp/data.cap host 
<server>) at the
time of the hang might also help...

steved.



-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
