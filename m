From: "William A.(Andy) Adamson" <andros@citi.umich.edu>
Subject: Re: FC3 <-> Solaris 10, NFSv4 interop?
Date: Fri, 25 Feb 2005 11:32:08 -0500
Message-ID: <20050225163208.98B9F1BB82@citi.umich.edu>
References: <1109296629.5897.574.camel@seki.nac.uci.edu>
 <200502251706.24315.vincent.roqueta@ext.bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D4iNv-0008Om-N0
	for nfs@lists.sourceforge.net; Fri, 25 Feb 2005 08:32:11 -0800
Received: from citi.umich.edu ([141.211.133.111])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D4iNu-0007Pp-A8
	for nfs@lists.sourceforge.net; Fri, 25 Feb 2005 08:32:11 -0800
To: Vincent Roqueta <vincent.roqueta@ext.bull.net>
In-reply-to: <200502251706.24315.vincent.roqueta@ext.bull.net> 
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

we have no SECINFO support in the NFSv4 server. therefore, with kerberos,=
 you=20
may have problems mounting. we will address this next week at connectatho=
n...

-->Andy

vincent.roqueta=40ext.bull.net said:
> Le vendredi 25 F=E9vrier 2005 02:57, Dan Stromberg a =E9crit=A0:
> Has anyone got NFSv4 working from an FC3 NFS server to a Solaris 10 NFS=

> client? >
> foobar-root /) mount seki.nac.uci.edu:/sdb1 /mnt
> nfs mount: mount: /mnt: Not owner
> foobar-root /) mount -o vers=3D3 seki.nac.uci.edu:/sdb1 /mnt
> foobar-root /)
> Yes. interop works fine.
> Vincent=20




-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
