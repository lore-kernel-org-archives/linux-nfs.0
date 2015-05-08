Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:56312 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752981AbbEHWeO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 May 2015 18:34:14 -0400
Date: Sat, 9 May 2015 00:34:12 +0200
From: Thorsten Kukuk <kukuk@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: libtirpc-devel@lists.sourceforge.net, linux-nfs@vger.kernel.org
Subject: Re: [PATCH V2] Fix Build w/gssapi disabled
Message-ID: <20150508223412.GA14634@suse.de>
References: <554B86E2.8090908@RedHat.com>
 <20150507163326.GA6156@suse.de>
 <554B98E9.4040601@RedHat.com>
 <20150507181206.GA7810@suse.de>
 <554BC53C.5080807@RedHat.com>
 <554BC730.3000004@RedHat.com>
 <554BC9F3.6020005@RedHat.com>
 <20150508020322.GF30924@vapier>
 <20150508081717.GA16376@suse.de>
 <554D2A4B.6040307@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <554D2A4B.6040307@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 08, Steve Dickson wrote:

> Hello Thorsten,
> 
> On 05/08/2015 04:17 AM, Thorsten Kukuk wrote:
> > On Thu, May 07, Mike Frysinger wrote:
> > 
> >> it is dangerous to export raw HAVE_xxx defines -- it can break packages that
> >> use autotools themselves.  they need an appropriate prefix like RPC_xxx or
> >> TIRPC_xxx.
> > 
> > 
> > For this and to solve the different size of the struct, I created
> > a new patch on top of current git. I only had to rearange the structs
> > a little bit, since they don't use any kerberos specific variables,
> > only standard C:
> I applied the following patch to the top of the git tree
> then I yum remove krb5-devel (which removes gssapi/gssapi.h)
> 
> After an 'sh autogen.sh' and ./configure --disable-gssapi 
> I'm getting the following compile errors 
>   http://ur1.ca/kbq67
> because gssapi.h does not exist.. 
>    
> What am I doing wrong??

Sorry, somehow my patch was incomplete, this part did go 
missing:

diff --git a/tirpc/rpc/rpcsec_gss.h b/tirpc/rpc/rpcsec_gss.h
index 217fc0d..f02de8a 100644
--- a/tirpc/rpc/rpcsec_gss.h
+++ b/tirpc/rpc/rpcsec_gss.h
@@ -35,8 +35,6 @@
 #include <rpc/auth.h>
 #include <rpc/clnt.h>
 
-#include <gssapi/gssapi.h>
-
 typedef enum {
        rpcsec_gss_svc_default  = 0,
        rpcsec_gss_svc_none     = 1,



-- 
Thorsten Kukuk, Senior Architect SLES & Common Code Base
SUSE LINUX GmbH, Maxfeldstr. 5, 90409 Nuernberg, Germany
GF: Felix Imendörffer, Jane Smithard, Dilip Upmanyu, Graham Norton, HRB 21284 (AG Nürnberg)
