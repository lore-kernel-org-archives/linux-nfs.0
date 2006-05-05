From: Neil Brown <neilb@suse.de>
Subject: Re: Folder in NFS-Share-Permission denied-but the user is group member
Date: Fri, 5 May 2006 21:45:01 +1000
Message-ID: <17499.15037.908665.125536@cse.unsw.edu.au>
References: <445B30FD.9040103@vwi.tu-dresden.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.94] (helo=sc8-sf-list2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FbykE-0002nk-9z
	for nfs@lists.sourceforge.net; Fri, 05 May 2006 04:45:14 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FbykE-0000MR-9r
	for nfs@lists.sourceforge.net; Fri, 05 May 2006 04:45:14 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FbykD-0005o9-Vf
	for nfs@lists.sourceforge.net; Fri, 05 May 2006 04:45:14 -0700
To: kolbe@vwi.tu-dresden.de
In-Reply-To: message from Steffen Kolbe on Friday May 5
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

On Friday May 5, kolbe@vwi.tu-dresden.de wrote:
> Hi,
> 
> - a client has mounted some nfs shares
> - in these shares are folders wich are owned by different groups
> - rights of these folders are 2770
> - getent group: user is member in these groups (on server and client via 
> ldap)
> 
> but access to these folders says "Permission denied"
> 
> - if I copy the folder to local disk this error does not occur and the 
> user has access
> 
> NFS-Server: Debian amd64 with nfs-kernel-server 1.0.7-12
> NFS-Client: Debian i386 with nfs-common 1.0.7-11
> 
> Can anybody help, where I should search ?

How many groups in the user a member of?  If >16, that could be the
problem.  NFS requests only carry the first 16 groups.

Otherwise, capture a tcpdump trace and post that somewhere.

  on client
   tcpdump -s 1500 -w /tmp/trace host CLIENT and host SERVER and port 2049
  then try to access file.

NeilBrown


-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
