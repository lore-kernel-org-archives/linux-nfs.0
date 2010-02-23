From: Steve Dickson <SteveD@redhat.com>
Subject: Re: pseudo root status?
Date: Tue, 23 Feb 2010 12:57:33 -0500
Message-ID: <4B84170D.1010803@RedHat.com>
References: <20100219190049.GA32080@esri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Ray Van Dolson <rvandolson-v48TKWNzwFw@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47162 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752140Ab0BWR5i (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Feb 2010 12:57:38 -0500
In-Reply-To: <20100219190049.GA32080-v48TKWNzwFw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/19/2010 02:00 PM, Ray Van Dolson wrote:
> What is the status of the dynamic pseudo root support in nfs-utils?  I
> see in commit b25694320f2bdd79de82f2003209b8229eafff36 mention of a way
> to define an export with a pseudo root, but I cloned Steve's latest git
> tree of nfs-utils and am not seeing much about pseudo root support at
> all.
> 
> The 1.2.2 announcement message seems to include a blurb about it --
> does this version have what I need?
The dynamic pseudo for v4 is fully supported in the Linux 2.6.33 kernel 
along with nfs-utils-1.2.2...

steved.
