Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:1885 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759834Ab3DISCr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Apr 2013 14:02:47 -0400
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r39I2l29023999
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 9 Apr 2013 14:02:47 -0400
Subject: Re: [PATCH 1/2] Avoid reverse resolution for server name
From: Simo Sorce <simo@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
In-Reply-To: <5164514A.7020606@RedHat.com>
References: <515B2F8D.3030302@RedHat.com>
	 <1364931149-18484-2-git-send-email-simo@redhat.com>
	 <5162C8A5.4030307@RedHat.com>
	 <1365430116.20560.6.camel@willson.li.ssimo.org>
	 <51644CC5.3070609@RedHat.com>
	 <1365528308.20560.42.camel@willson.li.ssimo.org>
	 <5164514A.7020606@RedHat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 09 Apr 2013 14:02:45 -0400
Message-ID: <1365530565.20560.43.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-04-09 at 13:35 -0400, Steve Dickson wrote:
> 
> On 09/04/13 13:25, Simo Sorce wrote:
> > On Tue, 2013-04-09 at 13:15 -0400, Steve Dickson wrote:
> >>
> >> On 08/04/13 10:08, Simo Sorce wrote:
> >>> On Mon, 2013-04-08 at 09:39 -0400, Steve Dickson wrote:
> >>>>
> >>>> On 02/04/13 15:32, Simo Sorce wrote:
> >>>>> A NFS client should be able to work properly even if the DNS Reverse record
> >>>>> for the server is not set. There is no excuse to forcefully prevent that
> >>>>> from working when it can.
> >>>>>
> >>>>> This patch adds a new pair of options (-z/-Z) that allow to turn on/off
> >>>>> DNS reverse resolution for determining the server name to use with GSSAPI.
> >>>> Again, please tell me why we need the -Z flag when that is the default?
> >>>
> >>> The idea is to switch the default in the code at some point, so then -Z
> >>> will be needed to get back to the original behavior.
> >> I'm thinking that's what major version number changes are for... not flags...
> >>
> >>>
> >>> The idea is that by having both flags a distribution may choose to
> >>> decide now what behavior they want and use the relative flag. Then even
> >>> if we change the default their configuration will not "break".
> >> I'll do the work to remove the option and repost the patches..
> > 
> > As you wish, I do not have hard preferences, should we take the bait and
> > also by default *not* do PTR lookups ?
> I was thinking no. Leaves the default as is and used the -z to avoid the
> lookup... 
> 
> I'm struggling with how big of a problem this really is, so why should be break
> existing environments? I'm no DNS expert but I thinking not have PTR is 
> a DNS config issue... but again I'm no expert...  

Read this:
http://ssimo.org/blog/id_015.html

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

