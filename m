From: Steve Dickson <SteveD@redhat.com>
Subject: Re: nfs problem: nfs could be mounted and viewed but errors
 on file opening
Date: Fri, 10 Sep 2004 07:22:36 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <41418E7C.80902@RedHat.com>
References: <1094795240.3169.17.camel@roach.aldevinco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C5jWv-0008Vu-Ib
	for nfs@lists.sourceforge.net; Fri, 10 Sep 2004 04:25:25 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1C5jWk-0003Wk-UV
	for nfs@lists.sourceforge.net; Fri, 10 Sep 2004 04:25:20 -0700
To: ronald rojas <alsonsdev_mis@dctech.com.ph>
In-Reply-To: <1094795240.3169.17.camel@roach.aldevinco.com>
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

ronald rojas wrote:

>i'm having problems opening my nfs mounted files on the client machine.
>Mounting the nfs share on the client goes ok. the user and group
>permissions are ok. i could even ls -l and cd into the mounted directory
>and subdirectories but when i open a file (cat somefile.txt) i get a
>segmentation fault. after that, umounting the nfs share seems to hang.
>
>i noticed this problem when i upgraded the kernel on the client machine
>from 2.4 to 2.6. (is there any relation?)
>
>server config:				client config:
>nfs-utils version 1.0.1			nfs-utils version 1.0.1
>kernel ver. 2.4.18-14			kernel ver. 2.6.8
>redhat 8.0 distro			fedora core 1.0
>  
>
I think you meant Fedora Core 2 since Fedora Core 1 is  2.4 based.
And also think my meant to say nfs-utils version 1.0.6 not 1.0.1

This being the case, please upgrade your nfs-utils to latest
version on rawhide (1.0.6-32 I believe) since the nfs-utils right out
of the box is a bit challenged when it comes to starting things
up in the correct order. Plus make sure rpc.imapd is running on the client.

SteveD.




-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM. 
Deadline: Sept. 13. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
