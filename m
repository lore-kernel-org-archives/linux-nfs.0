From: Le Rouzic <aime.le-rouzic@bull.net>
Subject: Re: NFSD IPv6 support for 2.6.29
Date: Mon, 17 Nov 2008 18:52:05 +0100
Message-ID: <4921AF45.4070009@bull.net>
References: <9BBD5BD5-C461-43C4-AEB0-69D3E31F92B7@oracle.com> <4917C380.9040703@linux.vnet.ibm.com> <C44F9C62-2770-4879-8AC7-B1C8D81F9AB6@oracle.com> <491AFE09.2010803@bull.net> <2BF8FCDB-0C6D-430E-B2AE-4C293E30A1AE@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070203030509020307050703"
Cc: Varun Chandramohan <varunc@linux.vnet.ibm.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:54738 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751461AbYKQRwO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2008 12:52:14 -0500
In-Reply-To: <2BF8FCDB-0C6D-430E-B2AE-4C293E30A1AE@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070203030509020307050703
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit

Chuck Lever a écrit :

>>> On Nov 10, 2008, at 12:15 AM, Varun Chandramohan wrote:
>>>
>>>> Chuck Lever wrote:
>>>>
>>>>> Hi Aime, Varun-
>>>>>
>>>>> Bruce asked me to collect server-side IPv6 patches for upstream.
>>>>> I've collected the patches that have been posted on the list, and
>>>>> added some fixes of my own.
>>>>>
>>>>> Can you have a look at
>>>>>
>>>>> http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=summary
>>>>>
>>>>> tag cel-ipv6-10292008
>>>>>
>>>>> These have been build tested, but I haven't done any run-time
>>>>> testing yet.
>>>>>
>>>>> -- 
>>>>> Chuck Lever
>>>>> chuck[dot]lever[at]oracle[dot]com
>>>>
>>>>
>>>> Hi Chuck,
>>>>
>>>>               I just realized that i forgot to update you about the
>>>> test result of your tree. I found NFSv4 over ipv6 working well. So
>>>> it can be pulled into the mainline soon.
>>>
 Hi
I have tested the "tag cel-ipv6-10292008" and some robustness tests
started simultaneously (connectathon, fsx, iozone, fss_stress, ffsb) have
been running fine during several hours in IPV6 and IPV4.
I used the my nfs-utils package based on nfs-utils.1.1.2 
(http://nfsv4.bullopensource.org/)

Nevertheless I may have missed something during the last mails about IPV6
but I don't find in your tree changes about IPV6 in fs/nfsd/nfsctl.c

I join the patch I submitted for that.

Best Regards


-- 
-----------------------------------------------------------------
Company : Bull, Architect of an Open World TM (www.bull.com)
Name    : Aime Le Rouzic 
Mail    : Bull - BP 208 - 38432 Echirolles Cedex - France
E-Mail  : aime.le-rouzic@bull.net
Phone   : 33 (4) 76.29.75.51
Fax     : 33 (4) 76.29.75.18
----------------------------------------------------------------- 


--------------070203030509020307050703
Content-Type: text/plain;
 name="patch_ipv6overrpcbindv4_nfsctl"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch_ipv6overrpcbindv4_nfsctl"


 NFSV4 IPV6: Adds AF_INET6 domain processing when AF_INET processing only available in nfsd/nfsctl.c

 ---

 fs/nfsd/nfsctl.c     |   41 +++++++++++++++++++++++++++++++----------

 Signed-off-by: Aime Le Rouzic <aime.le-rouzic@bull.net>
---
diff -Nru rpcbindv4/fs/nfsd/nfsctl.c ipv6overrpcbindv4/fs/nfsd/nfsctl.c
--- rpcbindv4/fs/nfsd/nfsctl.c	2008-09-15 14:50:09.000000000 +0200
+++ ipv6overrpcbindv4/fs/nfsd/nfsctl.c	2008-09-15 15:18:24.000000000 +0200
@@ -230,6 +230,7 @@
 {
 	struct nfsctl_fsparm *data;
 	struct sockaddr_in *sin;
+	struct sockaddr_in6 *sin6;
 	struct auth_domain *clp;
 	int err = 0;
 	struct knfsd_fh *res;
@@ -239,9 +240,19 @@
 		return -EINVAL;
 	data = (struct nfsctl_fsparm*)buf;
 	err = -EPROTONOSUPPORT;
-	if (data->gd_addr.sa_family != AF_INET)
+	switch (data->gd_addr.sa_family) {
+	case AF_INET:
+		sin = (struct sockaddr_in *)&data->gd_addr;
+		ipv6_addr_set_v4mapped(sin->sin_addr.s_addr, &in6);
+		break;
+	case AF_INET6:
+		sin6 = (struct sockaddr_in6 *)&data->gd_addr;
+		ipv6_addr_copy(&in6, &sin6->sin6_addr); 
+		break;
+	default:
 		goto out;
-	sin = (struct sockaddr_in *)&data->gd_addr;
+	}
+
 	if (data->gd_maxlen > NFS3_FHSIZE)
 		data->gd_maxlen = NFS3_FHSIZE;
 
@@ -249,8 +260,6 @@
 
 	exp_readlock();
 
-	ipv6_addr_set_v4mapped(sin->sin_addr.s_addr, &in6);
-
 	clp = auth_unix_lookup(&in6);
 	if (!clp)
 		err = -EPERM;
@@ -269,6 +278,7 @@
 {
 	struct nfsctl_fdparm *data;
 	struct sockaddr_in *sin;
+	struct sockaddr_in6 *sin6;
 	struct auth_domain *clp;
 	int err = 0;
 	struct knfsd_fh fh;
@@ -279,20 +289,31 @@
 		return -EINVAL;
 	data = (struct nfsctl_fdparm*)buf;
 	err = -EPROTONOSUPPORT;
-	if (data->gd_addr.sa_family != AF_INET)
+	if (data->gd_addr.sa_family != AF_INET &&
+	    data->gd_addr.sa_family != AF_INET6)
 		goto out;
+
 	err = -EINVAL;
 	if (data->gd_version < 2 || data->gd_version > NFSSVC_MAXVERS)
 		goto out;
 
 	res = buf;
-	sin = (struct sockaddr_in *)&data->gd_addr;
 	exp_readlock();
 
-	ipv6_addr_set_v4mapped(sin->sin_addr.s_addr, &in6);
+	switch (data->gd_addr.sa_family) {
+	case AF_INET:
+		sin = (struct sockaddr_in *)&data->gd_addr;
+		ipv6_addr_set_v4mapped(sin->sin_addr.s_addr, &in6);
+		break;
+	case AF_INET6:
+		sin6 = (struct sockaddr_in6 *)&data->gd_addr;
+		ipv6_addr_copy(&in6, &sin6->sin6_addr);
+		break;
+	default:
+		goto out;
+	}
 
-	clp = auth_unix_lookup(&in6);
-	if (!clp)
+	if (!(clp = auth_unix_lookup(&in6)))
 		err = -EPERM;
 	else {
 		err = exp_rootfh(clp, data->gd_path, &fh, NFS_FHSIZE);
@@ -305,7 +326,7 @@
 		memcpy(res, &fh.fh_base, fh.fh_size);
 		err = NFS_FHSIZE;
 	}
- out:
+out:
 	return err;
 }

--------------070203030509020307050703--
