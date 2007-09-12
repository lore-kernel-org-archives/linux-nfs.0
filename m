From: Le Rouzic <aime.le-rouzic@bull.net>
Subject: "used greatest stack depth: n bytes left" messages
Date: Wed, 12 Sep 2007 13:27:45 +0200
Message-ID: <46E7CD31.4080306@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfsv4 <nfsv4@linux-nfs.org>, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IVQLi-0003M6-UK
	for nfs@lists.sourceforge.net; Wed, 12 Sep 2007 04:25:39 -0700
Received: from ecfrec.frec.bull.fr ([129.183.4.8])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IVQLl-0005fV-Ee
	for nfs@lists.sourceforge.net; Wed, 12 Sep 2007 04:25:43 -0700
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




 Hi,

Since 2.6.23-RC5 we can get the following kind of messages in 
/var/log/messages:

Sep 11 12:22:40 frec kernel: loadkeys used greatest stack depth: 4568 
bytes left
Sep 11 12:22:40 frec kernel: rc.sysinit used greatest stack depth: 4448 
bytes left
Sep 11 12:22:40 frec kernel: readahead used greatest stack depth: 4264 
bytes left
Sep 11 13:38:36 frec kernel: mount.nfs4 used greatest stack depth: 4088 
bytes left
Sep 11 17:12:08 frec kernel: mount.nfs4 used greatest stack depth: 3512 
bytes left

Are there only WARNINGs?
Does that mean we need to act on some kernel parameter ? Which one?
Can we conclude anything is not normal?
How nfsv4 can be impacted in its behavior?



Cheers

-- 
-----------------------------------------------------------------
Company : Bull, Architect of an Open World TM (www.bull.com)
Name    : Aime Le Rouzic 
Mail    : Bull - BP 208 - 38432 Echirolles Cedex - France
E-Mail  : aime.le-rouzic@bull.net
Phone   : 33 (4) 76.29.75.51
Fax     : 33 (4) 76.29.75.18
----------------------------------------------------------------- 


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
