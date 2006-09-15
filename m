From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Strange NFS behaviour, working directory disappears
Date: Fri, 15 Sep 2006 01:39:09 -0400
Message-ID: <1158298749.5533.3.camel@lade.trondhjem.org>
References: <450AB68E.4A67.0005.0@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GO6QC-0002Pa-81
	for nfs@lists.sourceforge.net; Thu, 14 Sep 2006 22:39:28 -0700
Received: from pat.uio.no ([129.240.10.4])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GO6QB-0001pb-Hk
	for nfs@lists.sourceforge.net; Thu, 14 Sep 2006 22:39:29 -0700
To: max williams <max.williams@alliedtelesis.co.nz>
In-Reply-To: <450AB68E.4A67.0005.0@alliedtelesis.co.nz>
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

On Fri, 2006-09-15 at 14:19 +1200, max williams wrote:
> Hi,
> I have a strange issue on a number of PCs that mount /home via NFS.
> This started after upgrading the NFS server from Redhat 9 to Fedora
> Core 4. Very occasionally the current working directory or a
> particular file "disappears". When I say disappears I mean the client
> returns an odd error when running "ls -l" but on the NFS server the
> file/directory is fine.
> Example:
>  
> [root@tb39 maxw]# ls -l
> ls: log.txt: No such file or directory
> total 346704

You don't mention which kernel you are using. The latest FC4 kernel is
2.6.17 based: is that still giving you trouble?

Cheers,
  Trond


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
