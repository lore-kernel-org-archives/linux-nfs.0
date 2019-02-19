Return-Path: <SRS0=cCtV=Q2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D344C43381
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 19:41:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 04C8C2146F
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 19:41:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="JGNamIWr"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725987AbfBSTlJ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Feb 2019 14:41:09 -0500
Received: from aserp2130.oracle.com ([141.146.126.79]:54412 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725963AbfBSTlJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Feb 2019 14:41:09 -0500
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
        by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1JJXb8w065383;
        Tue, 19 Feb 2019 19:41:00 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=nz7oYBhVpy0ayYmsNZg428MaQwI1++GMUM5vFCyQUN4=;
 b=JGNamIWrYVjNqUj3RmrD6vFCP6YAdEx6dYqknh0k90r1rM11azYVGbRecOE3xNp2dLHl
 92sFg033cYEyBCPJ+bYCnTTrf/7gbOKIwttAoOMun0BW3zRKQO3z1A+cfz/85TIn3Xe2
 FozvQRgQcIPY49BPsLjucqUK8KeTsFLZtgI58RxGyW+moK8iAorXqckm8AeHCmClFrWF
 zL4HKj1TV8zoZkUkiQkwnTuBy9uEdzYoKwdPUlQTX15dnzeyecRuH6BRs5knt4bx5bFY
 6tP7M28MiEGi0/j2m3p7QjKkofRMe4u8Mede+Kvx6EnhJm8kV8wSNwPvYoCINry95agz RA== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
        by aserp2130.oracle.com with ESMTP id 2qp81e5juy-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Tue, 19 Feb 2019 19:41:00 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
        by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x1JJf0jF028031
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Tue, 19 Feb 2019 19:41:00 GMT
Received: from abhmp0004.oracle.com (abhmp0004.oracle.com [141.146.116.10])
        by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x1JJexHb021868;
        Tue, 19 Feb 2019 19:40:59 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Tue, 19 Feb 2019 11:40:59 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH v2] Remove abuse of ai_canonname
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20190219195729.6d893e98@onion.lan>
Date:   Tue, 19 Feb 2019 14:40:58 -0500
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Steve Dickson <SteveD@redhat.com>
Content-Transfer-Encoding: 7bit
Message-Id: <D9488568-838E-45BE-A58C-435581481B48@oracle.com>
References: <20190219155220.17240.31293.stgit@manet.1015granger.net>
 <20190219195729.6d893e98@onion.lan>
To:     Peter Wagner <tripolar@gmx.at>
X-Mailer: Apple Mail (2.3445.102.3)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9172 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902190138
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Feb 19, 2019, at 1:57 PM, Peter Wagner <tripolar@gmx.at> wrote:
> 
> Looks good to me.
> I run tested it on musl and in combination with me nfs_freeaddrinfo
> patch it works.

Very good. Let's see what Steve's testing shows up, if anything.


> I will post my patch in a few minutes
> 
> On Tue, 19 Feb 2019 10:52:36 -0500
> Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>> Peter Wagner <tripolar@gmx.at> reports a portability issue with
>> freeing ai_canonname (and subsequently replacing that pointer via
>> strdup(3)). The relevant standards text is:
>> 
>>> If nodename is not null, and if requested by the AI_CANONNAME
>>> flag, the ai_canonname field of the first returned addrinfo
>>> structure shall point to a null-terminated string containing the
>>> canonical name corresponding to the input nodename; if the
>>> canonical name is not available, then ai_canonname shall refer to
>>> the nodename argument or a string with the same contents.  
>> 
>> There is no indication that this string may be freed using free(3).
>> Eg, the library could have allocated it as part of the addrinfo
>> struct itself, or it could point to static memory. The Linux man
>> page is equally silent on this issue.
>> 
>> There is only one caller to host_reliable_addrinfo() that actually
>> uses the string in ai->ai_canonname, and then only for debugging
>> messages. Change those to display the IP address instead.
>> 
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> support/export/hostname.c |   58
>> +++++++++------------------------------------
>> utils/mountd/auth.c       |   16 ++++++------ 2 files changed, 20
>> insertions(+), 54 deletions(-)
>> 
>> 
>> Compile-tested only.
>> 
>> 
>> diff --git a/support/export/hostname.c b/support/export/hostname.c
>> index 5c4c824..96c5449 100644
>> --- a/support/export/hostname.c
>> +++ b/support/export/hostname.c
>> @@ -264,9 +264,9 @@ host_canonname(const struct sockaddr *sap)
>>  * Reverse and forward lookups are performed to ensure the address
>> has
>>  * matching forward and reverse mappings.
>>  *
>> - * Returns addrinfo structure with just the provided address with
>> - * ai_canonname filled in. If there is a problem with resolution or
>> - * the resolved records don't match up properly then it returns NULL
>> + * Returns addrinfo structure with just the provided address. If
>> there
>> + * is a problem with resolution or the resolved records don't match
>> up
>> + * properly then returns NULL.
>>  *
>>  * Caller must free the returned structure with freeaddrinfo(3).
>>  */
>> @@ -277,13 +277,15 @@ host_reliable_addrinfo(const struct sockaddr
>> *sap) struct addrinfo *ai, *a;
>> 	char *hostname;
>> 
>> +	ai = NULL;
>> 	hostname = host_canonname(sap);
>> 	if (hostname == NULL)
>> -		return NULL;
>> +		goto out;
>> 
>> 	ai = host_addrinfo(hostname);
>> +	free(hostname);
>> 	if (!ai)
>> -		goto out_free_hostname;
>> +		goto out;
>> 
>> 	/* make sure there's a matching address in the list */
>> 	for (a = ai; a; a = a->ai_next)
>> @@ -291,22 +293,15 @@ host_reliable_addrinfo(const struct sockaddr
>> *sap) break;
>> 
>> 	freeaddrinfo(ai);
>> +	ai = NULL;
>> 	if (!a)
>> -		goto out_free_hostname;
>> +		goto out;
>> 
>> 	/* get addrinfo with just the original address */
>> 	ai = host_numeric_addrinfo(sap);
>> -	if (!ai)
>> -		goto out_free_hostname;
>> 
>> -	/* and populate its ai_canonname field */
>> -	free(ai->ai_canonname);
>> -	ai->ai_canonname = hostname;
>> +out:
>> 	return ai;
>> -
>> -out_free_hostname:
>> -	free(hostname);
>> -	return NULL;
>> }
>> 
>> /**
>> @@ -323,7 +318,6 @@ host_numeric_addrinfo(const struct sockaddr *sap)
>> {
>> 	socklen_t salen = nfs_sockaddr_length(sap);
>> 	char buf[INET6_ADDRSTRLEN];
>> -	struct addrinfo *ai;
>> 	int error;
>> 
>> 	if (salen == 0) {
>> @@ -348,21 +342,7 @@ host_numeric_addrinfo(const struct sockaddr *sap)
>> 		return NULL;
>> 	}
>> 
>> -	ai = host_pton(buf);
>> -
>> -	/*
>> -	 * getaddrinfo(AI_NUMERICHOST) never fills in ai_canonname
>> -	 */
>> -	if (ai != NULL) {
>> -		free(ai->ai_canonname);		/* just in
>> case */
>> -		ai->ai_canonname = strdup(buf);
>> -		if (ai->ai_canonname == NULL) {
>> -			freeaddrinfo(ai);
>> -			ai = NULL;
>> -		}
>> -	}
>> -
>> -	return ai;
>> +	return host_pton(buf);
>> }
>> #else	/* !HAVE_GETNAMEINFO */
>> __attribute__((__malloc__))
>> @@ -372,7 +352,6 @@ host_numeric_addrinfo(const struct sockaddr *sap)
>> 	const struct sockaddr_in *sin = (const struct sockaddr_in
>> *)sap; const struct in_addr *addr = &sin->sin_addr;
>> 	char buf[INET_ADDRSTRLEN];
>> -	struct addrinfo *ai;
>> 
>> 	if (sap->sa_family != AF_INET)
>> 		return NULL;
>> @@ -382,19 +361,6 @@ host_numeric_addrinfo(const struct sockaddr *sap)
>> 					(socklen_t)sizeof(buf)) ==
>> NULL) return NULL;
>> 
>> -	ai = host_pton(buf);
>> -
>> -	/*
>> -	 * getaddrinfo(AI_NUMERICHOST) never fills in ai_canonname
>> -	 */
>> -	if (ai != NULL) {
>> -		ai->ai_canonname = strdup(buf);
>> -		if (ai->ai_canonname == NULL) {
>> -			freeaddrinfo(ai);
>> -			ai = NULL;
>> -		}
>> -	}
>> -
>> -	return ai;
>> +	return host_pton(buf);
>> }
>> #endif	/* !HAVE_GETNAMEINFO */
>> diff --git a/utils/mountd/auth.c b/utils/mountd/auth.c
>> index 8299256..cb4848c 100644
>> --- a/utils/mountd/auth.c
>> +++ b/utils/mountd/auth.c
>> @@ -261,40 +261,40 @@ auth_authenticate(const char *what, const
>> struct sockaddr *caller, *p = '\0';
>> 	}
>> 
>> +	host_ntop(caller, buf, sizeof(buf));
>> 	switch (error) {
>> 	case bad_path:
>> 		xlog(L_WARNING, "bad path in %s request from %s:
>> \"%s\"",
>> -		     what, host_ntop(caller, buf, sizeof(buf)),
>> path);
>> +		     what, buf, path);
>> 		break;
>> 
>> 	case unknown_host:
>> 		xlog(L_WARNING, "refused %s request from %s for %s
>> (%s): unmatched host",
>> -		     what, host_ntop(caller, buf, sizeof(buf)),
>> path, epath);
>> +		     what, buf, path, epath);
>> 		break;
>> 
>> 	case no_entry:
>> 		xlog(L_WARNING, "refused %s request from %s for %s
>> (%s): no export entry",
>> -		     what, ai->ai_canonname, path, epath);
>> +		     what, buf, path, epath);
>> 		break;
>> 
>> 	case not_exported:
>> 		xlog(L_WARNING, "refused %s request from %s for %s
>> (%s): not exported",
>> -		     what, ai->ai_canonname, path, epath);
>> +		     what, buf, path, epath);
>> 		break;
>> 
>> 	case illegal_port:
>> 		xlog(L_WARNING, "refused %s request from %s for %s
>> (%s): illegal port %u",
>> -		     what, ai->ai_canonname, path, epath,
>> nfs_get_port(caller));
>> +		     what, buf, path, epath, nfs_get_port(caller));
>> 		break;
>> 
>> 	case success:
>> 		xlog(L_NOTICE, "authenticated %s request from %s:%u
>> for %s (%s)",
>> -		     what, ai->ai_canonname, nfs_get_port(caller),
>> path, epath);
>> +		     what, buf, nfs_get_port(caller), path, epath);
>> 		break;
>> 	default:
>> 		xlog(L_NOTICE, "%s request from %s:%u for %s (%s)
>> gave %d",
>> -		     what, ai->ai_canonname, nfs_get_port(caller),
>> -			path, epath, error);
>> +		     what, buf, nfs_get_port(caller), path, epath,
>> error); }
>> 
>> 	freeaddrinfo(ai);
>> 
> 

--
Chuck Lever



