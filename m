From: Steve Dickson <SteveD@RedHat.com>
Subject: Re: Typo in Redhat 8/9 nfs start/stop script
Date: Tue, 24 Jun 2003 08:19:53 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EF841E9.1050408@RedHat.com>
References: <D38AFB3080F3D311807300B0D0203E53033A9622@MERCURY>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from host-64-179-20-100.man.choiceone.net ([64.179.20.100] helo=Odyssey.Home.4Dicksons.Org)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19UmmO-0000LC-00
	for <nfs@lists.sourceforge.net>; Tue, 24 Jun 2003 05:20:08 -0700
To: pwitting@Cyveillance.com
In-Reply-To: <D38AFB3080F3D311807300B0D0203E53033A9622@MERCURY>
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

pwitting@Cyveillance.com wrote:

>You may want to do more than that. RH9 is using 2.4.20 kernel, which by my
>understanding resets the values to what I thinks is reasonable. For details
>on how 2.4.20 calculates queue sizes, see this earlier post by Neil Brown:
>
>http://sourceforge.net/mailarchive/message.php?msg_id=4229482
>
>But the gist is, there is no longer any need for the startup script to reset
>these values unless RH has disabled this feature of the kernel nfs code. 
>
Good point... That QS stuff probably should be removed...

>Secondly, it might be wise to automatically install a /etc/sysconfig/nfs
>file. The script reads this file, but there's no default included, only be
>reading and understanding the script would a user find out that this is now
>the preferred way to change the thread count.
>
I kinda like it the way it is.... I don't want to make it too easy for 
people to
shoot themselves in the foot.... :-)  Making people read/understand the 
script
before changing it seems to me like a good idea...

>Finally, why not release an erratum that corrects the problem instead of
>forcing any upgrade to RH10? It would be nice if I didn't have to add
>functions to my Kickstart post-install script to correct this problem, and
>instead could just upgrade the RPM in my install directory.
>
You don't have to upgrade the RH10 to get these changes... just
upgrade the nfs-utils package...

SteveD.



-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
