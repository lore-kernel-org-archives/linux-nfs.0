From: Steve Dickson <SteveD@redhat.com>
Subject: Re: nfs_statfs: statfs error = 116
Date: Thu, 18 Sep 2003 09:49:47 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F69B7FB.1050505@RedHat.com>
References: <3F698142.6070404@inf.ethz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19zzAU-0004Py-00
	for <nfs@lists.sourceforge.net>; Thu, 18 Sep 2003 06:49:58 -0700
Received: from pix-525-pool.redhat.com ([66.187.233.200] helo=lacrosse.corp.redhat.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19zzAK-00006s-Ox
	for nfs@lists.sourceforge.net; Thu, 18 Sep 2003 06:49:48 -0700
To: Marc Schmitt <mschmitt@inf.ethz.ch>
In-Reply-To: <3F698142.6070404@inf.ethz.ch>
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



Marc Schmitt wrote:

>
> My questions are:
>
> - Is this a race? 

It sounds to me like it could be be a server issue under
a very heavy load...  How many nfsd are you running? Try
increasing the number to see if that helps....

>
> - Is there a way to get the client working again w/o having to reboot 
> (or kill all the users processes and umount the home if that's 
> possible)? I tried restarting rpc.statd on the client but that did not 
> help.

not really... :(

> - How can I provide more debugging infos if needed? 

ethereal traces have more information and are
generally more useful... imo...

SteveD.




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
