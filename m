From: Jeff Layton <jlayton@poochiereds.net>
Subject: Re: Issues with 2.6.21-rc4/5 and slowlaris 8
Date: Thu, 29 Mar 2007 13:58:48 -0400
Message-ID: <460BFE58.2030809@poochiereds.net>
References: <350605.5583.qm@web90512.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Phy Prabab <phyprabab@yahoo.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HWyti-0001rc-AM
	for nfs@lists.sourceforge.net; Thu, 29 Mar 2007 10:58:54 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HWytk-0004nN-FY
	for nfs@lists.sourceforge.net; Thu, 29 Mar 2007 10:58:56 -0700
In-Reply-To: <350605.5583.qm@web90512.mail.mud.yahoo.com>
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

Phy Prabab wrote:
> Hello again,
> 
> So it looks like I have to make a small correction, I do indeed see this 
> problem on Solaris 10 on intel.  Interestingly, the first time I 
> untarred the files, everything went smoothly - I was even able to remove 
> the entire package without issue.  However, upon the second untarring, I 
> started to get errors about permissions and directories not being 
> there.  I am inclined to think this is a caching issue.
> 
> Any help?
> TIA,
> Phy
> 
> ----- Original Message ----
> From: Phy Prabab <phyprabab@yahoo.com>
> To: nfs@lists.sourceforge.net
> Sent: Tuesday, March 27, 2007 12:32:16 PM
> Subject: Issues with 2.6.21-rc4/5 and slowlaris 8
> 
> Hello,
> 
> I am having some issues with slowlaris 8 sparc and linux 2.6.21-rc4/5 
> (actually, 2.6.20.x as well) with directory permissions.  The client is 
> the slowlaris box mounting a file system (XFS, LVM, DM, 3Ware 9650) from 
> the linux box.  I extract some files from a tar ball and then try to 
> delete them, I get permission denied, however, the files are owned by my 
> uid and the file permissions are 775.  Any help figuring this out would 
> be most welcome.  I can provide plenty of debugging if needed.
> 
> TIA!
> Phy
> 

Just a SWAG, but you might want to try disabling ACL's when mounting and see if 
that makes any difference.
-- Jeff


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
