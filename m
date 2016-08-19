Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:44800 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755321AbcHSU44 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Aug 2016 16:56:56 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [RFC PATCH 1/3] libnfsidmap: Query DNS for the the NFSv4 domain
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1471545435-15543-1-git-send-email-steved@redhat.com>
Date: Fri, 19 Aug 2016 16:56:32 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <8AE29A85-1437-470F-BF7D-087641728511@oracle.com>
References: <1471545435-15543-1-git-send-email-steved@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Aug 18, 2016, at 2:37 PM, Steve Dickson <SteveD@redhat.com> wrote:
> 
> In domain_from_dns(), when at the hostname is a FQHN
> query the DNS server for the _nfsv4idmapdomain TXT
> record. If the record exists, use that as the
> NFSv4 domain.
> 
> Note, this query will only happen if the domain name
> is not set in the /etc/idmapd.conf
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>

All three:

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>


> ---
> libnfsidmap.c | 104 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
> 1 file changed, 103 insertions(+), 1 deletion(-)
> 
> diff --git a/libnfsidmap.c b/libnfsidmap.c
> index 2db4d13..7b8c0ed 100644
> --- a/libnfsidmap.c
> +++ b/libnfsidmap.c
> @@ -53,6 +53,10 @@
> #include <stdarg.h>
> #include <dlfcn.h>
> #include <ctype.h>
> +#include <resolv.h>
> +#include <arpa/nameser.h>
> +#include <arpa/nameser_compat.h>
> +
> #include "nfsidmap.h"
> #include "nfsidmap_internal.h"
> #include "cfg.h"
> @@ -79,6 +83,11 @@ gid_t nobody_gid = (gid_t)-1;
> #define IDMAPD_DEFAULT_DOMAIN "localdomain"
> #endif
> 
> +#ifndef NFS4DNSTXTREC
> +#define NFS4DNSTXTREC "_nfsv4idmapdomain"
> +#endif
> +
> +
> /* Default logging fuction */
> static void default_logger(const char *fmt, ...)
> {
> @@ -114,6 +123,93 @@ static int id_as_chars(char *name, uid_t *id)
> 	return 1;
> }
> 
> +static int dns_txt_query(char *domain, char **nfs4domain)
> +{
> +	char *txtname = NFS4DNSTXTREC;
> +	char *msg, *answ, *eom, *mptr; 
> +	int len, status = -1;
> +	HEADER *hdr;
> +	
> +	msg = calloc(1, NS_MAXMSG);
> +	if (msg == NULL)
> +		return -1;
> +
> +	answ = calloc(1, NS_MAXMSG);
> +	if (answ == NULL) {
> +		free(msg);
> +		return -1;
> +	}
> +
> +	if (res_init() < 0) {
> +		IDMAP_LOG(2, ("libnfsidmap: res_init() failed for %s.%s: %s\n",
> +			txtname, domain, hstrerror(h_errno)));
> +		goto freemem;
> +	}
> +	len = res_querydomain(txtname, domain, C_IN, T_TXT, msg, NS_MAXMSG);
> +	if (len < 0) {
> +		IDMAP_LOG(2, ("libnfsidmap: res_querydomain() failed for %s.%s: %s\n",
> +			txtname, domain, hstrerror(h_errno)));
> +		goto freemem;
> +	}
> +	hdr = (HEADER *)msg;
> +
> +	/* See if there is an answer */
> +	if (ntohs(hdr->ancount) < 1) {
> +		IDMAP_LOG(2, ("libnfsidmap: No TXT record for %s.%s\n",
> +			txtname, domain));
> +		goto freemem;
> +	}
> +	/* find the EndOfMessage */
> +	eom = msg + len;
> +
> +	/* skip header */
> +	mptr = &msg[HFIXEDSZ];
> +
> +	/* skip name field in question section */
> +	mptr += dn_skipname(mptr, eom) + QFIXEDSZ;
> +
> +	/* read in the question */
> +	len = dn_expand(msg, eom, mptr, answ, NS_MAXDNAME);
> +	if (len < 0) { /* does this really matter?? */
> +		IDMAP_LOG(2, ("libnfsidmap: No question section for %s.%s: %s\n",
> +			txtname, domain, hstrerror(h_errno)));
> +		goto freemem;
> +	}
> +
> +	/*
> +	 * Now, dissect the answer section, Note: if there
> +	 * are more than one answer only the first
> +	 * one will be used. 
> +	 */
> +
> +	/* skip passed the name field  */
> +	mptr += dn_skipname(mptr, eom);
> +	/* skip pass the type class and ttl fields */
> +	mptr += 2 + 2 + 4;
> +
> +	/* make sure there is some data */
> +	GETSHORT(len, mptr);
> +	if (len < 0) {
> +		IDMAP_LOG(2, ("libnfsidmap: No data in answer for %s.%s\n",
> +			txtname, domain));
> +		goto freemem;
> +	}
> +	/* get the lenght field */
> +	len = (int)*mptr++;
> +	/* copy the data */
> +	memcpy(answ, mptr, len);
> +	answ[len] = '\0';
> +	
> +	*nfs4domain = strdup(answ);
> +	status = 0;
> +
> +freemem:
> +	free(msg);
> +	free(answ);
> +
> +	return (status);
> +}
> +
> static int domain_from_dns(char **domain)
> {
> 	struct hostent *he;
> @@ -125,7 +221,13 @@ static int domain_from_dns(char **domain)
> 		return -1;
> 	if ((c = strchr(he->h_name, '.')) == NULL || *++c == '\0')
> 		return -1;
> -	*domain = strdup(c);
> +	/* 
> +	 * Query DNS to see if the _nfsv4idmapdomain TXT record exists
> +	 * If so use it... 
> +	 */
> +	if (dns_txt_query(c, domain) < 0)
> +		*domain = strdup(c);
> +
> 	return 0;
> }
> 
> -- 
> 2.7.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



