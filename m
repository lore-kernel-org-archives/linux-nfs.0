From: Andreas Gruenbacher <agruen@suse.de>
Subject: Re: [Acl-Devel] [PATCH] Stop call_decode() from ignorning
	RPC header errrors
Date: 27 Aug 2003 13:08:30 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1061982510.1492.6.camel@chaos.suse.de>
References: <3F43B13C.5010403@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net,
	linux-kernel <linux-kernel@vger.kernel.org>, acl-devel@bestbits.at
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19ryAF-0003XL-00
	for <nfs@lists.sourceforge.net>; Wed, 27 Aug 2003 04:08:35 -0700
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.22)
	id 19ryAE-0005cX-QW
	for nfs@lists.sourceforge.net; Wed, 27 Aug 2003 04:08:35 -0700
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <3F43B13C.5010403@RedHat.com>
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

Hi Steve,

thanks a lot for the patch. It helps.


On Wed, 2003-08-20 at 19:34, Steve Dickson wrote:
> This patch stop call_decode() from ignoring errors
> that are found while parsing the RPC header. I turns
> out the nfs acls routines need these error codes to do
> the right thing...
> 
> SteveD.




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
