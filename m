From: Brian Pontz <axehind007@yahoo.com>
Subject: bash-2.05b$ touch foo
Date: Thu, 7 Aug 2003 15:37:34 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030807223734.71021.qmail@web14409.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from web14409.mail.yahoo.com ([216.136.173.220])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19ktO2-0008NI-00
	for <nfs@lists.sourceforge.net>; Thu, 07 Aug 2003 15:37:34 -0700
To: nfs@lists.sourceforge.net
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

Hello all,

I know I must be missing something here. I'm trying to
get all creates to my nfs mounted fs to be created as
a certain user. But when I try to create a file with
touch I get

bash-2.05b$ touch foo
touch: setting times of `foo': Permission denied

but it does create the file with the right uid/gid.

The export for the fs looks like this

/nfs/home 
10.0.0.200(rw,async,wdelay,root_squash,all_squash,anonuid=500,anongid=15000)

and the nfs client fstab entry looks like

10.0.0.201:/nfs/home/data       nfs     
noatime,exec,dev,nosuid,rw,bg,hard,int
r 1 1

What am I doing wrong? They are both RH9 systems.

Thanks
Brian


__________________________________
Do you Yahoo!?
Yahoo! SiteBuilder - Free, easy-to-use web site design software
http://sitebuilder.yahoo.com


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
