From: canon@nersc.gov
Subject: Re: Mounting > 2TB via NFS?
Date: Wed, 10 Jul 2002 12:26:07 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200207101926.g6AJQ7h32128@pookie.nersc.gov>
References: <Pine.LNX.4.44.0207101129390.24725-100000@ashi.FootPrints.net>
Cc: Jared Proudfoot <jproudfo@FootPrints.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pookie.nersc.gov ([128.55.16.113])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17SN6I-0005I9-00
	for <nfs@lists.sourceforge.net>; Wed, 10 Jul 2002 12:26:10 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: Your message of "Wed, 10 Jul 2002 12:04:48 PDT."
             <Pine.LNX.4.44.0207101129390.24725-100000@ashi.FootPrints.net>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>



It should work fine.  I think nfsv3 is required though.

Here is empirical proof...

[root@ahost /root]# df /beta/
Filesystem           1k-blocks      Used Available Use% Mounted on
xx.xx.xx.xx:/      4292664320 4135454256 157210064  96% /auto/beta1

Only the names have been changed to protect the innocent.  :-)

--Shane

> 
> 
> Greetings,
> 
> Perhaps this isn't the right list to post this question on.  If so, please 
> let me know.
> 
> I want to NFS export a filesystem from a Solaris machine to a Linux CPU
> farm (running stock mix of Redhat 7.x).  The filesystem we are exporting
> is over 2 TB in size.
> 
> There is some concern that the Linux boxes will not support mounting a 
> filesystem larger than 2 TB in size, due to a kernel limitation.
> 
> It is my understanding that Linux can not mount local filesystems that 
> are more than 2 TB in size, but is the same true for remote NFS 
> filesystems?  Does the same kernel limitation effect both NFS and local 
> filesystems?
> 
> I am not subscribed to this mailing list, so if you could reply to me 
> directly, I would appreciate it.
> 
> 
> Thanks in advance,
> 
> Jared Proudfoot
> 
> -- 
> Jared Proudfoot
> E-mail: jproudfo@FootPrints.net
> Home Page: http://jared.proudfoot.ca/
> 
> 
> 
> 
> -------------------------------------------------------
> This sf.net email is sponsored by:ThinkGeek
> Two, two, TWO treats in one.
> http://thinkgeek.com/sf
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Two, two, TWO treats in one.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
