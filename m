From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: directory depth limit?
Date: Fri, 8 Aug 2003 09:48:58 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200308080948.59738.bernd-schubert@web.de>
References: <20030807205633.DC0861833A@zachs.place.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from smtp02.web.de ([217.72.192.151] helo=smtp.web.de)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19l1zs-0002wt-00
	for <nfs@lists.sourceforge.net>; Fri, 08 Aug 2003 00:49:12 -0700
To: Paul Jimenez <pj@place.org>,
 nfs@lists.sourceforge.net
In-Reply-To: <20030807205633.DC0861833A@zachs.place.org>
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

On Thursday 07 August 2003 22:56, Paul Jimenez wrote:
> Hi,
>
>   I'm using kernel 2.4.20 under debian stable ('woody') and the
> user-land nfs server, and I can't seem to traverse more than about 23 or
> 24 levels deep into a directory structure over NFS.  Works fine on a local
> ext2 or ext3 fs, but not when that fs is exported via the abovementioned
> userland server.  And it's definitely related to directory depth and
> not PATHLEN because it fails even with single-char directory names for
> the entire depth.  So is this limit on the client, the server, or in the
> protocol?  And is it a bug or just a design limit?
>
> Thanks for your help,
>

Hi,

nfsv2 (nfsv3 is not supported by unfsd!) only allows 32 byte to decode the 
entire nfs-filehandle, so if one would use the pathname encoded by characters 
this would fail rather fast. IMHO all nfs-server use the inodes for 
encrypting the path.
Well, unfsd has 28 bytes to encrypt the complete pathname via inodes (32 bit) 
and hashtable into those 28 bytes. I guess that you have reached the 
unfsd-limit.

The knfsd does different, as far as I understand it, the file handle only 
consist of the file inode, the inode of the parent directory, a file creation 
number and I think some other stuff. Anyway the 32 byte are sufficient here 
to encode the pathname. 

NFS-experts, please correct me if I'm wrong. Btw, I still don't understand how 
the knfs-algorithm works, if the dentry-cache has no information about 
parent-inode/inode (e.g. after a server reboot). How does the kernel figures 
out the proper path in that case?

Best regards,
	Bernd

PS: Paul, why do you insist on using unfsd. Knfsd does a much better job! 
Well, there are a few exception for using unfsd, ClusterNFS is one of them, 
but you have to be very carefull on using of it.



-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
