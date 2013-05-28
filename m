Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:53607 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759193Ab3E1SB4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 May 2013 14:01:56 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r4SI1u4k019339
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 28 May 2013 14:01:56 -0400
Received: from smallhat.bos.devel.redhat.com ([10.16.60.65])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id r4SI1t1f000792
	for <linux-nfs@vger.kernel.org>; Tue, 28 May 2013 14:01:56 -0400
Message-ID: <51A4F113.4050605@RedHat.com>
Date: Tue, 28 May 2013 14:01:55 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsidmap: Don't check ENABLE_LDAP twice
References: <20130525220217.GA4330@master.debian.org>
In-Reply-To: <20130525220217.GA4330@master.debian.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 25/05/13 18:02, Aníbal Monsalve Salazar wrote:
> To build the Debian libnfsidmap package, I've used the patch in this
> mail for more than a year.
> 
> Debian-BTS: http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=661215
> Author: Steve Langasek <steve.langasek@ubuntu.com>
> Description: Don't check ENABLE_LDAP twice
>  This source is already being conditionally compiled based on ENABLE_LDAP
>  being set in the Makefile.  All this extra check does is cause umich_ldap.so
>  to always be compiled as an *EMPTY* object because nothing sets ENABLE_LDAP
>  before the #ifdef!
> Bug-Ubuntu: https://bugs.launchpad.net/bugs/939232
Committed...

steved.
> 
> diff -up a/umich_ldap.c b/umich_ldap.c
> --- a/umich_ldap.c	2011-12-06 07:28:10.000000000 +1100
> +++ b/umich_ldap.c	2012-02-27 13:21:34.000000000 +1100
> @@ -32,8 +32,6 @@
>   * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
>   */
>  
> -#ifdef ENABLE_LDAP
> -
>  #include <sys/types.h>
>  #include <sys/socket.h>
>  #include <netdb.h>
> @@ -1302,4 +1300,3 @@ struct trans_func *libnfsidmap_plugin_in
>  {
>  	return (&umichldap_trans);
>  }
> -#endif
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
