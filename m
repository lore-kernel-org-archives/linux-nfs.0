Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:32454 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752223Ab2JZK4J (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Oct 2012 06:56:09 -0400
Message-ID: <508A6C46.2070309@RedHat.com>
Date: Fri, 26 Oct 2012 06:56:06 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: lux-integ <lux-integ@btconnect.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: nfs-utils, --enable-gss   librpcsecgss.so glitch
References: <201210260234.04247.lux-integ@btconnect.com>
In-Reply-To: <201210260234.04247.lux-integ@btconnect.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 25/10/12 21:34, lux-integ wrote:
> Greetings,
> 
> I hope I am posting to the right list.  
> 
> I am trying to compile nfs-utils  on a cblfs setup  with (
> gcc-4.6.3, 
>  linx-3.6.3, 
> kerberos-10.3
> as well as 
> librpcsecgss-0.19 and
> libgssglue-0.4 )
> 
> 
> I tried  nfs-utils 1.2.5, 1.2.6. and r.1.2.7rc7  In all  instances  
> 
>  with the --disable-gss ,  compilation sicceeds 
> BUT
> with --enable-gss (the default)
> make ends like so.
> #########
> /usr/lib/librpcsecgss.so: undefined reference to `__rpc_thread_svc_fdset'
> collect2: ld returned 1 exit status
> make[2]: *** [gssd] Error 1
> ########
This was define in glibc... I wonder if its deprecated

steved.
> 
> The thing is, I want the gss feature  for an NFSv4 setup.
> 
> I have successfully compiled earlier versions of nfs-utils   on hosts  with 
> earlier versions of kerberos, librpcsecgss-and libgssglue
> 
> I would be grateful for advice concerning  the current setup and result(s)
> 
> sincerely
> lux-integ
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
