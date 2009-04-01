From: Greg Banks <gnb-xTcybq6BZ68@public.gmane.org>
Subject: Re: [patch 00/29] SGI enhancedNFS patches
Date: Wed, 1 Apr 2009 17:41:34 +1100
Message-ID: <ac442c870903312341v77876650ye996a25931cddaa@mail.gmail.com>
References: <20090331202800.739621000@sgi.com>
	 <20090401002306.GC26583@fieldses.org>
	 <ac442c870903312032t34630c6dvdbb644cb510f8079@mail.gmail.com>
	 <49D30B04.900@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Greg Banks <gnb@sgi.com>,
	Linux NFS ML <linux-nfs@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.228]:37142 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755864AbZDAGlg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Apr 2009 02:41:36 -0400
Received: by rv-out-0506.google.com with SMTP id f9so3453791rvb.1
        for <linux-nfs@vger.kernel.org>; Tue, 31 Mar 2009 23:41:34 -0700 (PDT)
In-Reply-To: <49D30B04.900@garzik.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 1, 2009 at 5:34 PM, Jeff Garzik <jeff@garzik.org> wrote:
> Greg Banks wrote:
>>
>> On Wed, Apr 1, 2009 at 11:23 AM, J. Bruce Fields <bfields@fieldses.org>
>> wrote:
>>>
>>> On Wed, Apr 01, 2009 at 07:28:00AM +1100, Greg Banks wrote:
>>
>>>> Bruce: all of these are potentially candidates for 2.6.30.
>>>
>>> It's probably too late for 2.6.30 (the 4.1 stuff I've promised to try to
>>> make a serious attempt at, but that's it).  I'll publish a for-2.6.31
>>> branch as soon as I can....  (But of course anything that looks like a
>>> bugfix I'll keep considering for 2.6.30.)
>>
>> No worries.  I figured as much, but the patches really did need to be
>> posted this week.
>
> So, what is enhancedNFS?  Does enhancedNFS comply with current RFCs, or
> deviate?
>
> What features does it add?

It uses the same protocols.  The server is faster and more scalable
and has more statistics to drive the web-based management UI.  The
name is perhaps poorly chosen.

-- 
Greg.
