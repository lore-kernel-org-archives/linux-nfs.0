From: Frank Cusack <fcusack@fcusack.com>
Subject: Re: NFS directory caching
Date: Tue, 24 Jun 2003 03:32:58 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030624033258.D4036@google.com>
References: <75587E33AC778145AACCE1601EEABF420D496F@kda-beexc-02.kda.kongsberg.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 216-239-45-4.google.com ([216.239.45.4])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Ul6q-0001BF-00
	for <nfs@lists.sourceforge.net>; Tue, 24 Jun 2003 03:33:08 -0700
To: "Mikkelborg, Kjetil" <kjetil.mikkelborg@kongsberg.com>
In-Reply-To: <75587E33AC778145AACCE1601EEABF420D496F@kda-beexc-02.kda.kongsberg.com>; from kjetil.mikkelborg@kongsberg.com on Tue, Jun 24, 2003 at 11:06:02AM +0200
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

On Tue, Jun 24, 2003 at 11:06:02AM +0200, Mikkelborg, Kjetil wrote:
> How is it with directory caching in standard nfs client for linux? Is it
> existent at all? And if so, is there any way I can modify its timeout
> values for spesific mountpoint?

man 5 nfs

...

> It would be nice to eliminate the issue with extensive NFS directories
> in path problem, without altering the existing PATH setting, since for
> managment reasons it is much more easier to have most of the common
> tools on a NFS volume than installed on each workstation.

For some types of software, yes.  I would have disagreed until recently
(now that my site is moving away from that).

/fc


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
