From: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
Subject: Re: nfs root directory security
Date: Wed, 18 Jun 2003 11:30:54 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0306181123090.5031-100000@kenzo.iwr.uni-heidelberg.de>
References: <16111.57576.494626.387349@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Scott Leerssen <scott@leerssen.com>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.iwr.uni-heidelberg.de ([129.206.104.30])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19SZHc-0002bP-00
	for <nfs@lists.sourceforge.net>; Wed, 18 Jun 2003 02:31:12 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16111.57576.494626.387349@gargle.gargle.HOWL>
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

On Wed, 18 Jun 2003, Neil Brown wrote:

> So you want to hide the names from people who don't know them.

Security through obscurity rarely works...

> Alternately just export the subdirectories rather than the parent.
> Export different subdirectories to different clients.

I think that this is the only solution that makes sense. Obviously you 
need a script to take care of the /etc/exports file and upon any 
modification run the 'exportfs' command. But you do this already, don't 
you ? Or you maintain the hundreds or thousands client directories by 
hand ???
The fact the the clients know what priviledges they have and can change 
permissions sounds very strange to me from a security point of view...

-- 
Bogdan Costescu

IWR - Interdisziplinaeres Zentrum fuer Wissenschaftliches Rechnen
Universitaet Heidelberg, INF 368, D-69120 Heidelberg, GERMANY
Telephone: +49 6221 54 8869, Telefax: +49 6221 54 8868
E-mail: Bogdan.Costescu@IWR.Uni-Heidelberg.De



-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
