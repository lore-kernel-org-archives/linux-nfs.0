From: "Steve French (smfltc)" <smfltc@us.ibm.com>
Subject: Re: Re: [PATCH] usb-storage: don't call utsname()
Date: Wed, 21 May 2008 13:19:32 -0500
Message-ID: <483467B4.1060601@us.ibm.com>
References: <20080521123700.GA8770@infradead.org>	<Pine.LNX.4.44L0.0805211349480.3409-100000@iolanthe.rowland.org> <20080521180957.GA17598@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	Matthew Dharm <mdharm-usb-JGfshJpz5UybPZpvUQj5UqxOck334EZe@public.gmane.org>,
	Christoph Hellwig <hch@infradead.org>,
	"Frank Ch. Eigler" <fche@redhat.com>,
	Adrian Bunk <bunk@kernel.org>,
	USB Storage list <usb-storage-ijkIwGHArpdIPJnuZ7Njw4oP9KaGy4wf@public.gmane.org>,
	Kernel development list <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem-xgOahHnHvIuGfricDzPwBeTW4wlIGRCZ@public.gmane.org>,
	systemtap-R2MHTz/CkKAf7BdofF/totBPR1lH4CV8@public.gmane.org,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-cifs-client@lists.samba.org, linux-nfs@vger.kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:38951 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755087AbYEUSSn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 May 2008 14:18:43 -0400
In-Reply-To: <20080521180957.GA17598@kroah.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Greg KH wrote:
> On Wed, May 21, 2008 at 01:51:17PM -0400, Alan Stern wrote:
>   
>> This patch (as1100) replaces the core-kernel function call to utsname()
>> in usb-storage with the UTS_RELEASE macro.  It's used only for warning
>> about extra unusual_devs entries.
>>
>> Signed-off-by: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
>>     
>
> Why?  With this change, if you change the version number, the file will
> have to be rebuilt.  Without the change, the file will not need to be
> rebuilt, right?
>
> I thought that was why this change was made a while ago, to prevent
> things from having to be rebuilt that didn't need to be
>   
I agree - what was wrong with utsname->release ... it seems odd to 
statically build the kernel's version
number into a module - it should be something we should be able to query 
(and it shouldn't change without
reboot so accessing it is not racy).  Access to other fields in the 
structure (nodename, domainname etc.) might
need to be included in a macro but I didn't see one in utsname.h for this.
