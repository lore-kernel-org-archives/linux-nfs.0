From: Kevin Jamieson <kevin@kevinjamieson.com>
Subject: Re: several oopses of nfsd in 2.6.16.29 (patch)
Date: Wed, 06 Dec 2006 02:29:48 -0800
Message-ID: <45769B9C.4080009@kevinjamieson.com>
Reply-To: kevin@kevinjamieson.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gru68-0001l1-LP
	for nfs@lists.sourceforge.net; Wed, 06 Dec 2006 02:33:56 -0800
Received: from shawidc-mo1.cg.shawcable.net ([24.71.223.10]
	helo=pd5mo1so.prod.shaw.ca)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Gru68-0002Ts-R6
	for nfs@lists.sourceforge.net; Wed, 06 Dec 2006 02:33:58 -0800
Received: from pd4mr4so.prod.shaw.ca
	(pd4mr4so-qfe3.prod.shaw.ca [10.0.141.215]) by l-daemon
	(Sun ONE Messaging Server 6.0 HotFix 1.01 (built Mar 15 2004))
	with ESMTP id <0J9U00348L544WA0@l-daemon> for nfs@lists.sourceforge.net;
	Wed, 06 Dec 2006 03:29:28 -0700 (MST)
Received: from pn2ml2so.prod.shaw.ca ([10.0.121.146])
	by pd4mr4so.prod.shaw.ca (Sun Java System Messaging Server 6.2-7.05
	(built Sep
	5 2006)) with ESMTP id <0J9U00LDHL540DJ1@pd4mr4so.prod.shaw.ca> for
	nfs@lists.sourceforge.net; Wed, 06 Dec 2006 03:29:28 -0700 (MST)
Received: from mail.kevinjamieson.com ([24.87.84.75])
	by l-daemon (Sun ONE Messaging Server 6.0 HotFix 1.01 (built Mar 15
	2004))
	with ESMTP id <0J9U004CWL54ZJW0@l-daemon> for nfs@lists.sourceforge.net;
	Wed, 06 Dec 2006 03:29:28 -0700 (MST)
Received: from [192.168.1.110] (bender.lan.kevinjamieson.com [192.168.1.110])
	by mail.kevinjamieson.com (Postfix) with ESMTP id 87E3FE6326	for
	<nfs@lists.sourceforge.net>; Wed, 06 Dec 2006 02:30:02 -0800 (PST)
To: nfs@lists.sourceforge.net
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Kevin Jamieson wrote:

> I am seeing similar oopses on a 2.6.16.21 Linux server in conjunction 
> with a Solaris 8 client using NFSv2 with ACL support enabled (although 
> no ACLs actually created). The problem does not occur with NFSv3 or with 
> ACL support disabled.

I believe I've tracked the problem I'm seeing down to the release function for the setacl/getattr/access procedures in fs/nfsd/nfs2acl.c having the wrong type for the resp parameter.

The below patch (against SuSE's 2.6.16.21-0.8) appears to resolve the problem (in limited testing thus far).

Kevin


--- linux-2.6.16.21-0.8/fs/nfsd/nfs2acl.c.bak	2006-12-05 23:42:27.000000000 +0000
+++ linux-2.6.16.21-0.8/fs/nfsd/nfs2acl.c	2006-12-06 10:06:01.000000000 +0000
@@ -287,8 +287,15 @@
 	return 1;
 }
 
-static int nfsaclsvc_release_fhandle(struct svc_rqst *rqstp, u32 *p,
-		struct nfsd_fhandle *resp)
+static int nfsaclsvc_release_attrstat(struct svc_rqst *rqstp, u32 *p,
+		struct nfsd_attrstat *resp)
+{
+	fh_put(&resp->fh);
+	return 1;
+}
+
+static int nfsaclsvc_release_access(struct svc_rqst *rqstp, u32 *p,
+		struct nfsd3_accessres *resp)
 {
 	fh_put(&resp->fh);
 	return 1;
@@ -322,9 +329,9 @@
 static struct svc_procedure		nfsd_acl_procedures2[] = {
   PROC(null,	void,		void,		void,	  RC_NOCACHE, ST),
   PROC(getacl,	getacl,		getacl,		getacl,	  RC_NOCACHE, ST+1+2*(1+ACL)),
-  PROC(setacl,	setacl,		attrstat,	fhandle,  RC_NOCACHE, ST+AT),
-  PROC(getattr, fhandle,	attrstat,	fhandle,  RC_NOCACHE, ST+AT),
-  PROC(access,	access,		access,		fhandle,  RC_NOCACHE, ST+AT+1),
+  PROC(setacl,	setacl,		attrstat,	attrstat, RC_NOCACHE, ST+AT),
+  PROC(getattr, fhandle,	attrstat,	attrstat, RC_NOCACHE, ST+AT),
+  PROC(access,	access,		access,		access,   RC_NOCACHE, ST+AT+1),
 };
 
 struct svc_version	nfsd_acl_version2 = {



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
