From: Denis Vlasenko <vda@ilport.com.ua>
Subject: [PATCH] treat N.N.N.N as MCL_SUBNETWORK instead of MCL_FQDN
Date: Wed, 9 Mar 2005 10:15:06 +0200
Message-ID: <200503091013.13999.vda@port.imtp.ilyichevsk.odessa.ua>
References: <200503041424.22897.vda@ilport.com.ua> <200503051557.07721.vda@ilport.com.ua> <16939.39051.569756.982757@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_KCrLCCNXgey0JVU"
Cc: nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>, vital@ilport.com.ua
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8wLx-0008Hz-6P
	for nfs@lists.sourceforge.net; Wed, 09 Mar 2005 00:15:37 -0800
Received: from [195.66.192.167] (helo=port.imtp.ilyichevsk.odessa.ua)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.41)
	id 1D8wLq-0004la-Nv
	for nfs@lists.sourceforge.net; Wed, 09 Mar 2005 00:15:37 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>,
	Denis Vlasenko <vda@ilport.com.ua>
In-Reply-To: <16939.39051.569756.982757@cse.unsw.edu.au>
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


--Boundary-00=_KCrLCCNXgey0JVU
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Meanwhile, this patch prevents exportfs from translating
numeric IPs into hostnames for /var/lib/nfs/etab.
Adheres to principle of least surprise. Avoids DNS lookups.
--
vda





--Boundary-00=_KCrLCCNXgey0JVU
Content-Type: text/x-diff;
  charset="koi8-r";
  name="client.c.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="client.c.diff"

--- nfs-utils-1.0.7/support/export/client.c.orig	Wed Sep 15 04:58:40 2004
+++ nfs-utils-1.0.7/support/export/client.c	Wed Mar  9 10:04:53 2005
@@ -138,7 +138,9 @@ client_init(nfs_client *clp, const char 
 
 	if (clp->m_type == MCL_SUBNETWORK) {
 		char	*cp = strchr(clp->m_hostname, '/');
+		static char slash32[] = "/32";
 
+		if(!cp) cp = slash32;
 		*cp = '\0';
 		clp->m_addrlist[0].s_addr = inet_addr(clp->m_hostname);
 		if (strchr(cp + 1, '.')) {
@@ -443,5 +445,12 @@ client_gettype(char *ident)
 		if (*sp == '\\' && sp[1])
 			sp++;
 	}
-	return MCL_FQDN;
+	/* check for N.N.N.N */
+	sp = ident;
+	if(!isdigit(*sp) || strtoul(sp, &sp, 10) > 255 || *sp != '.') return MCL_FQDN;
+	sp++; if(!isdigit(*sp) || strtoul(sp, &sp, 10) > 255 || *sp != '.') return MCL_FQDN;
+	sp++; if(!isdigit(*sp) || strtoul(sp, &sp, 10) > 255 || *sp != '.') return MCL_FQDN;
+	sp++; if(!isdigit(*sp) || strtoul(sp, &sp, 10) > 255 || *sp != '\0') return MCL_FQDN;
+	/* we lie here a bit. but technically N.N.N.N == N.N.N.N/32 :) */
+	return MCL_SUBNETWORK;
 }

--Boundary-00=_KCrLCCNXgey0JVU--



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
