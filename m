Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53256 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753957Ab3JQNQn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Oct 2013 09:16:43 -0400
Date: Thu, 17 Oct 2013 09:16:42 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Wangminlan <wangminlan@huawei.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Neil Brown <neilb@suse.de>
Subject: Re: Different sequence of "exportfs" produce different effects on
 nfs client mounts
Message-ID: <20131017131642.GF19067@fieldses.org>
References: <3962238FD7EA0F41B1810E7ABEAFBC314CEF9ACF@szxema505-mbs.china.huawei.com>
 <20131014174540.GA27747@fieldses.org>
 <3962238FD7EA0F41B1810E7ABEAFBC314CEF9E97@szxema505-mbs.china.huawei.com>
 <20131015154918.GA6117@fieldses.org>
 <3962238FD7EA0F41B1810E7ABEAFBC314CEF9FD9@szxema505-mbs.china.huawei.com>
 <3962238FD7EA0F41B1810E7ABEAFBC314CEFA2F5@szxema505-mbs.china.huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <3962238FD7EA0F41B1810E7ABEAFBC314CEFA2F5@szxema505-mbs.china.huawei.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 17, 2013 at 07:16:36AM +0000, Wangminlan wrote:
> Hi, 
> 	I went through the code of nfs-utils, check the function client_gettype in support/export/client.c:
> in nfs-utils-1-2-9-rc6, and in nfs-utils-1.2.6, they have this implementation in the final part:
>  770         /*
>  771          * Treat unadorned IP addresses as MCL_SUBNETWORK.
>  772          * Everything else is MCL_FQDN.
>  773          */
>  774         ai = host_pton(ident);
>  775         if (ai != NULL) {
>  776                 freeaddrinfo(ai);
>  777                 return MCL_SUBNETWORK;
>  778         }
>  779 
>  780         return MCL_FQDN;
>  781 }
> 
> while back in days of nfs-utils-1.0.7: client_gettype looks like this:
>  277 client_gettype(char *ident)
>  278 {
>  279         char    *sp;
>  280 
>  281         if (ident[0] == '\0')
>  282                 return MCL_ANONYMOUS;
>  283         if (ident[0] == '@') {
>  284 #ifndef HAVE_INNETGR
>  285                 xlog(L_WARNING, "netgroup support not compiled in");
>  286 #endif
>  287                 return MCL_NETGROUP;
>  288         }
>  289         for (sp = ident; *sp; sp++) {
>  290                 if (*sp == '*' || *sp == '?' || *sp == '[')
>  291                         return MCL_WILDCARD;
>  292                 if (*sp == '/')
>  293                         return MCL_SUBNETWORK;
>  294                 if (*sp == '\\' && sp[1])
>  295                         sp++;
>  296         }
>  297         return MCL_FQDN;
>  298 }
> 
> It's simple, and client like "192.168.0.21" is treated as MCL_FQDN. 
> I tried the same operation in this version, there's no such problem as in nfs-utils-1.2.1 and nfs-utils-1.2.6.

It looks like the change in behavior was intentional, see below.

Neil, do you remember what motivated that change?

I think Minlan Wang's right about what the behavior should be:

	- it's what's still documented by "man exports".
	- it seems least surprising.
	- the ability to override networks with specific ip addresses is
	  useful.  (Another alternative might be to classify them all as
	  MCL_SUBNETWORK and then always give smaller networks
	  priority.)

--b.

commit 54669c988cc7609a4aab1021604244424ebb795a
Author: neilbrown <neilbrown>
Date:   Mon Mar 14 02:18:19 2005 +0000

    treat N.N.N.N as a special case of MCL_SUBNETWORK instead of
    MCL_FQDN

diff --git a/ChangeLog b/ChangeLog
index e2a38f2..d0985f8 100644
--- a/ChangeLog
+++ b/ChangeLog
@@ -1,5 +1,11 @@
+2005-03-14  NeilBrown <neilb@cse.unsw.edu.au>
+	Denis Vlasenko <vda@ilport.com.ua>
+	* support/export/client.c(client_init and client_gettype):
+	treat N.N.N.N as a special case of MCL_SUBNETWORK instead of 
+	MCL_FQDN
+
 2005-03-06  G. Allen Morris III <gam3@gam3.net>
-	* support/nfs/cacheio.c(readline): Could not real lines greater
+	* support/nfs/cacheio.c(readline): Could not read lines greater
 	than 128 bytes. [1157791] 
 	* utils/exportfs/exports.man: Added a SEE ALSO section and
 	fixed 2 typos. [1018450]
diff --git a/support/export/client.c b/support/export/client.c
index 3884795..57176d8 100644
--- a/support/export/client.c
+++ b/support/export/client.c
@@ -138,7 +138,9 @@ client_init(nfs_client *clp, const char *hname, struct hostent *hp)
 
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
