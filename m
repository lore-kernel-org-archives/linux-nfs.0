Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:22212 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751888Ab3DJLLY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Apr 2013 07:11:24 -0400
Message-ID: <516548D8.3070707@redhat.com>
Date: Wed, 10 Apr 2013 12:11:20 +0100
From: Jose Castillo <jcastillo@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>, steved@redhat.com
Subject: Re: [PATCH] Add the missing '$' in auth_unix_ip()
References: <1365522899-29123-1-git-send-email-jcastillo@redhat.com> <20130409191113.GC3800@fieldses.org>
In-Reply-To: <20130409191113.GC3800@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/09/2013 08:11 PM, J. Bruce Fields wrote:
> Could you explain a little more?
> 
> I assume this is something I forgot to do as part of 
> c2544b77566690ebec32a2d47c9249548b1a0941 "mountd: prepend '$' to
> make use_ipaddr clients self-describing" but I haven't thought
> about that in a while....
> 

Hello,

Yes, sorry, a bit more of background: We found this problem because
NFS clients to a RHEL6 NFS server were experiencing periods of ESTALE
errors after being mounted and initially working successfully.
Tests were run which snapshotted the nfs/sunrpc caches before and
after the issue, and it was found that the '$' character at the
beginning of the ID strings, used when in use_ipaddr mode, was getting
lost:

GOOD, while mount was working:
#class IP domain
# expiry=1362416801 refcnt=2 flags=1
nfsd 1.2.3.4 $1.2.3.4

BAD, after mount started returning ESTALE:
#class IP domain
# expiry=1362418641 refcnt=2 flags=1
nfsd 1.2.3.4 1.2.3.4

This would then cause the export checks to fail by passing '1.2.3.4'
instead of '$1.2.3.4' up to rpc.mountd.

The problem appears to be in the auth_unix_ip() function when renewing
the auth.unix.ip cache entry.  It would fail to add the '$' character
back to the beginning of the string used for the domain string,
breaking the use_ipaddr mode.

The issue is reliably repeatable with large numbers of exports and
netgroups to cause rpc.mountd to enter use_ipaddr mode.

Steps to reproduce:

1. Export several hundred exports each with its own unique netgroup
2. Mount from a client (NFS3).  check
/proc/net/rpc/auth.unix.ip/content to ensure the '$' character is
there from use_ipaddr mode.
3. Wait long enough for the entry to expire (1 hour was used), and try
and access a file from the client.  It returned ESTALE and the
/proc/net/rpc/auth.unix.ip/content was now missing the '$' character.

Actual results:
Mount returns ESTALE on the client after being mounted for an extended
period of time.

Expected results:
File access should succeed on the mount.

The patch was tested in a reproduction environment, and the issue
could no longer be reproduced.

> --b.
> 
> On Tue, Apr 09, 2013 at 04:54:59PM +0100, Jose Castillo wrote:
>> Signed-off-by: Jose Castillo <jcastillo@redhat.com> --- 
>> utils/mountd/cache.c | 10 ++++++---- 1 file changed, 6
>> insertions(+), 4 deletions(-)
>> 
>> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c index
>> 978698d..e1027f3 100644 --- a/utils/mountd/cache.c +++
>> b/utils/mountd/cache.c @@ -80,7 +80,7 @@ static void
>> auth_unix_ip(FILE *f) */ char *cp; char class[20]; -	char
>> ipaddr[INET6_ADDRSTRLEN]; +	char ipaddr[INET6_ADDRSTRLEN + 1]; 
>> char *client = NULL; struct addrinfo *tmp = NULL; if
>> (readline(fileno(f), &lbuf, &lbuflen) != 1) @@ -94,7 +94,7 @@
>> static void auth_unix_ip(FILE *f) strcmp(class, "nfsd") != 0) 
>> return;
>> 
>> -	if (qword_get(&cp, ipaddr, sizeof(ipaddr)) <= 0) +	if
>> (qword_get(&cp, ipaddr, sizeof(ipaddr) - 1) <= 0) return;
>> 
>> tmp = host_pton(ipaddr); @@ -116,9 +116,11 @@ static void
>> auth_unix_ip(FILE *f) qword_print(f, "nfsd"); qword_print(f,
>> ipaddr); qword_printtimefrom(f, DEFAULT_TTL); -	if (use_ipaddr) +
>> if (use_ipaddr) { +		memmove(ipaddr + 1, ipaddr, strlen(ipaddr) +
>> 1); +		ipaddr[0] = '$'; qword_print(f, ipaddr); -	else if
>> (client) +	} else if (client) qword_print(f,
>> *client?client:"DEFAULT"); qword_eol(f); xlog(D_CALL,
>> "auth_unix_ip: client %p '%s'", client, client?client:
>> "DEFAULT"); -- 1.7.11.7
>> 
>> -- To unsubscribe from this list: send the line "unsubscribe
>> linux-nfs" in the body of a message to majordomo@vger.kernel.org 
>> More majordomo info at
>> http://vger.kernel.org/majordomo-info.html


