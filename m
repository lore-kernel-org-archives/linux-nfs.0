From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: cp: failed to preserve ownership for
	`/backup2/restart':	Operation not permitted
Date: Tue, 25 Sep 2007 19:09:19 -0400
Message-ID: <1190761759.6698.4.camel@heimdal.trondhjem.org>
References: <2127a07b0709251439s674dc1act8c37f64c789e4657@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Mark Maggelet <mark@educationplanet.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IaJXY-0002Bx-8Z
	for nfs@lists.sourceforge.net; Tue, 25 Sep 2007 16:10:04 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IaJXb-0003qs-UN
	for nfs@lists.sourceforge.net; Tue, 25 Sep 2007 16:10:09 -0700
In-Reply-To: <2127a07b0709251439s674dc1act8c37f64c789e4657@mail.gmail.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Tue, 2007-09-25 at 14:39 -0700, Mark Maggelet wrote:
> Hi,
> Sorry if this has been covered.
> I'm trying to mount a nfs share from my nas to my linux server(rhel4).
> I get this error and the file permissions of the copied file appear as
> nfsnobody.nfsnobody
> 
> Is there a way to keep permissions?
> 
> Thanks,
> - Mark

It sounds like the /etc/passwd and /etc/groups files on your client and
server are out of sync: please make sure that the username+uid and
groupname+gid match on both machines.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
