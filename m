From: Olaf Kirch <okir@suse.de>
Subject: Re: async vs. sync
Date: Wed, 28 Jul 2004 14:49:54 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040728124954.GJ20264@suse.de>
References: <482A3FA0050D21419C269D13989C61130435E51E@lavender-fe.eng.netapp.com> <200407270006.08581.bernd-schubert@web.de> <20040728085644.GD20264@suse.de> <200407281435.54555.bernd-schubert@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bpnwl-0002oi-FD
	for nfs@lists.sourceforge.net; Wed, 28 Jul 2004 05:54:15 -0700
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1Bpnwl-0002eO-05
	for nfs@lists.sourceforge.net; Wed, 28 Jul 2004 05:54:15 -0700
To: Bernd Schubert <bernd-schubert@web.de>
In-Reply-To: <200407281435.54555.bernd-schubert@web.de>
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

On Wed, Jul 28, 2004 at 02:35:51PM +0200, Bernd Schubert wrote:
> Well, I only see this on 2.6. systems, but not on 2.4., are there similar 
> triggers in 2.4.?  With 2.6. we don't have the problem at all.

On 2.4 you'd have to play with the bdflush tunables. I cant
remember what all these numbers mean; consult the documentation.
But there are also some tunables there that let you configure
when bdflush starts writing out dirty pages.

Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
