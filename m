From: Benjamin Bennett <ben@phys.psu.edu>
Subject: NFSv2/3 requiring RPC_AUTH_GSS
Date: Thu, 03 Mar 2005 17:54:53 -0500
Message-ID: <1109890493.4361.95.camel@roadrunner.phys.psu.edu>
Mime-Version: 1.0
Content-Type: text/plain
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D6zDk-0008Es-Kc
	for nfs@lists.sourceforge.net; Thu, 03 Mar 2005 14:55:04 -0800
Received: from faraday.phys.psu.edu ([128.118.49.2])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1D6zDi-0006sj-3e
	for nfs@lists.sourceforge.net; Thu, 03 Mar 2005 14:55:04 -0800
To: nfs@lists.sourceforge.net
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

Hi Folks,

  I've been trying the linux nfsv4 and rpcsec implementation exporting
from RHEL4 (2.6.9) to FC2 (2.6.9 & 2.6.10) and Solaris (8 & 10).

  v4 exports using gss/krb5 work from both FC2 and Solaris 10 clients.
However, for Solaris 8 I'm using v3 with gss/krb5.

  The problem I've run into with this, is that in order for the v3
client to mount (even using gss), it must be given sys/unix access too.
That pretty much rules out the nice sleep I could have gotten with all
clients using gss since they could just remount with auth_unix at will.

  To work around this, I've modified knfsd and nfs-utils to support an
additional export flag, req_gss. This flag does the same thing as the
secure/insecure flag, however it's checking the rpc auth flavor instead
of the client port. While this solution may have some issues with
RFC2623, it works well for Solaris 8 clients if you have creds at mount
time (kinit from keytab). This will not work for Linux v2/3 clients
since they use auth_unix for the fsinfo/getattr, however I do not
foresee having linux clients that support rpc_auth_gss and NOT v4, so
this isn't really an issue.

/etc/exports looks like:
/home   gss/krb5(rw,fsid=0,sync,insecure,no_subtree_check)
/home   gss/krb5i(rw,fsid=0,sync,insecure,no_subtree_check)
/home   gss/krb5p(rw,fsid=0,sync,insecure,no_subtree_check)
/home   *(req_gss,rw,fsid=0,sync,insecure,no_subtree_check)


Does anyone know of a better solution or see problems doing this (other
than incompatibility mentioned above)?


--ben



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
