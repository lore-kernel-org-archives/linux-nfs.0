Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60898 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752644AbbEHV1v (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 May 2015 17:27:51 -0400
Message-ID: <554D2A4B.6040307@RedHat.com>
Date: Fri, 08 May 2015 17:27:39 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Thorsten Kukuk <kukuk@suse.de>, libtirpc-devel@lists.sourceforge.net,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH V2] Fix Build w/gssapi disabled
References: <1430983149-22199-1-git-send-email-vapier@gentoo.org> <20150507115248.GA20243@suse.de> <554B86E2.8090908@RedHat.com> <20150507163326.GA6156@suse.de> <554B98E9.4040601@RedHat.com> <20150507181206.GA7810@suse.de> <554BC53C.5080807@RedHat.com> <554BC730.3000004@RedHat.com> <554BC9F3.6020005@RedHat.com> <20150508020322.GF30924@vapier> <20150508081717.GA16376@suse.de>
In-Reply-To: <20150508081717.GA16376@suse.de>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello Thorsten,

On 05/08/2015 04:17 AM, Thorsten Kukuk wrote:
> On Thu, May 07, Mike Frysinger wrote:
> 
>> it is dangerous to export raw HAVE_xxx defines -- it can break packages that
>> use autotools themselves.  they need an appropriate prefix like RPC_xxx or
>> TIRPC_xxx.
> 
> 
> For this and to solve the different size of the struct, I created
> a new patch on top of current git. I only had to rearange the structs
> a little bit, since they don't use any kerberos specific variables,
> only standard C:
I applied the following patch to the top of the git tree
then I yum remove krb5-devel (which removes gssapi/gssapi.h)

After an 'sh autogen.sh' and ./configure --disable-gssapi 
I'm getting the following compile errors 
  http://ur1.ca/kbq67
because gssapi.h does not exist.. 
   
What am I doing wrong??

steved.
