From: Alexander Jolk <alexj@buf.com>
Subject: Re: Stale NFS mounts
Date: Wed, 02 Nov 2005 10:07:04 +0100
Message-ID: <436881B8.5040403@buf.com>
References: <9E621559095AA746B22B21CD4FAF99A54E3126@EDINMAIL1.ad.datcon.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EXEaR-0005ZY-BA
	for nfs@lists.sourceforge.net; Wed, 02 Nov 2005 01:07:15 -0800
Received: from mail.buf.fr ([195.68.52.65])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44)
	id 1EXEaO-0008IN-OV
	for nfs@lists.sourceforge.net; Wed, 02 Nov 2005 01:07:15 -0800
To: Edward Hibbert <Edward.Hibbert@dataconnection.com>
In-Reply-To: <9E621559095AA746B22B21CD4FAF99A54E3126@EDINMAIL1.ad.datcon.co.uk>
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

Edward Hibbert wrote:
> I'm having a problem with stale mount points.

Might this be related to the problem described in 
http://linux.derkeiler.com/Mailing-Lists/Kernel/2003-09/7161.html?  You 
could try the export option `no_subtree_check' to see whether that helps.

Alex


-- 
Alexander Jolk  * BUF Compagnie * alexj@buf.com
Tel +33-1 42 68 18 28  *  Fax +33-1 42 68 18 29


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. Download
it for free - -and be entered to win a 42" plasma tv or your very own
Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
