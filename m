From: Kashif Shaikh <kshaikh@consensys.com>
Subject: Re: re-exporting: exportfs gives Invalid argument
Date: 01 Nov 2002 16:41:48 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1036186910.12957.157.camel@kashif>
References: <ACEAKKINMBBEGMOOHHNAGEDPCGAA.rych@chem.scphys.kyoto-u.ac.jp>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [216.187.68.150] (helo=c.pexit.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 187jZy-0008I5-00
	for <nfs@lists.sourceforge.net>; Fri, 01 Nov 2002 13:43:46 -0800
To: Igor Rychkov <rych@chem.scphys.kyoto-u.ac.jp>
In-Reply-To: <ACEAKKINMBBEGMOOHHNAGEDPCGAA.rych@chem.scphys.kyoto-u.ac.jp>
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

On Thu, 2002-10-31 at 06:17, Igor Rychkov wrote:
> Hi,
> I have the following situation: "A" client of 
network "N" needs file access to the "C" server of 
network "M", and there's "B" with 2 network cards. 
The computers have RedHat 7.2 or 7.3 installed.
> 
> B mounts Cshare on /Bshare/Cshare
> 
> B's /etc/exports includes the following lines:
> 
> /Bshare              A(rw,async,no_subtree_check,no_root_squash)
> /Bshare/Cshare       A(rw,nohide,async,no_subtree_check,no_root_squash)
> 
> then 
> B:# exportfs -ra
> gives
> A.N:/Bshare/Cshare: Invalid argument

IIRC, I don't think you can mount nfs export points, and then export
such shares through nfs.  If you search the archives, you will find
people encountering similar problems.

Kashif 





-------------------------------------------------------
This sf.net email is sponsored by: See the NEW Palm 
Tungsten T handheld. Power & Color in a compact size!
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
