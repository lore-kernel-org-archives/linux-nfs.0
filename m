From: Steve Dickson <SteveD@redhat.com>
Subject: Re: setting specific lockd port for NFS .....................
Date: Sun, 29 Apr 2007 19:34:53 -0400
Message-ID: <46352B9D.1040805@RedHat.com>
References: <OFEC0E3912.B7B7120F-ON852572C9.003D6E9D-852572C9.003E3796@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Terry Spaulding <spauld@us.ibm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HiIu5-0007wo-JM
	for nfs@lists.sourceforge.net; Sun, 29 Apr 2007 16:34:05 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HiIu7-0008Ol-0x
	for nfs@lists.sourceforge.net; Sun, 29 Apr 2007 16:34:08 -0700
In-Reply-To: <OFEC0E3912.B7B7120F-ON852572C9.003D6E9D-852572C9.003E3796@us.ibm.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net



Terry Spaulding wrote:
> List....
> 
> Has anyone been successful in setting a specific port for lockd to use with
> NFS ?
The nfslock init script in Fedora Core can do this...

steved.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
