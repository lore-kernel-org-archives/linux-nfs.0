From: Patrick O'Reilly <patrick.oreilly@uni.edu>
Subject: Re: Linux -> Sun NFS doesn't mount
Date: Tue, 25 Jun 2002 15:59:19 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <005701c21c8b$2cfb8c30$66f1a186@OREILLY>
References: <20020624223641.GA16108@backlot.linas.org>
 <shsptygs21r.fsf@charged.uio.no> <3D17B3F7.1010301@actusa.net>
 <20020625004215.GB16309@backlot.linas.org>
 <20020625203020.13900.qmail@mail.hostasaurus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from viper.uni.edu ([134.161.1.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17MxPm-0005RP-00
	for <nfs@lists.sourceforge.net>; Tue, 25 Jun 2002 13:59:54 -0700
Received: from OREILLY ([134.161.241.102]) by uni.edu (PMDF V6.1-1 #39731)
 with SMTP id <01KJCQFU4OR48WW36O@uni.edu> for nfs@lists.sourceforge.net; Tue,
 25 Jun 2002 15:59:43 -0500 (CDT)
To: webmaster <webmaster@dglewis.com>
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

I have a Solaris 8 NFS server mounting to 25 Redhat 7.1 clients.  I had much
trouble with the same type of thing, the mount was fine as long as the user
was root, but as soon as a non-root user logged on, the data disappeared
even the mount still persisted.  My log did have the same message.  After
much tinkering, I at one point added "log,nosuid" to my /etc/dfs/dfstab
options and the mounts on the Linux machines now are good.  I am not sure if
it was this exact thing that helped, but it's addition seemed to coincide
with the time the mounts became persistent.  Good Luck!

Patrick

_______________________________________
Patrick O'Reilly
Meteorological Decision Support Scientist
The STORM Project - University of Northern Iowa
patrick.oreilly@uni.edu  ~  ph: 319-273-3789

----- Original Message -----
From: "webmaster" <webmaster@dglewis.com>
Cc: <nfs@lists.sourceforge.net>
Sent: Tuesday, June 25, 2002 3:30 PM
Subject: [NFS] Linux -> Sun NFS doesn't mount


> After a recent upgrade from solaris 2.6 to 2.8, my linux nfs client can no
> longer nfs mount to the sun machine.  I can mount to two other 2.8 boxes
> w/out problems(they were installed fresh as 2.8 and since only patched
up).
> I get permission denied, however dmesg reveals:
>
> call_verify: server requires stronger authentication
>
> While googling I came across many references to linux nfs not being
capable
> of kerberos authentication, but haven't found a resolution or work around.
> I hope this is the appropriate forum.  In trolling here for the past week
it
> seems to be.
>
> Can anyone give me more insight or progress of a fix?  Thank you very much
> in advance for your attention.
>
> Dan
>
>
>
> -------------------------------------------------------
> This sf.net email is sponsored by: Jabber Inc.
> Don't miss the IM event of the season | Special offer for OSDN members!
> JabConf 2002, Aug. 20-22, Keystone, CO http://www.jabberconf.com/osdn
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs



-------------------------------------------------------
This sf.net email is sponsored by: Jabber Inc.
Don't miss the IM event of the season | Special offer for OSDN members! 
JabConf 2002, Aug. 20-22, Keystone, CO http://www.jabberconf.com/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
