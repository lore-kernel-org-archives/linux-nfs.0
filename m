From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfsmount.conf: New variables that explicitly set
	default
Date: Fri, 23 Oct 2009 13:20:02 -0400
Message-ID: <20091023172002.GA31133@fieldses.org>
References: <6E43AB0D-AC26-411F-A8CF-146E02F8AADA@oracle.com> <4ACFC458.8060107@RedHat.com> <BB5B8D78-DAF9-4087-AC84-9BE4F95DA11C@oracle.com> <4AD2F5B7.9040900@RedHat.com> <21B26104-0D0E-4362-8CE7-B567921B3314@oracle.com> <4AD36309.1090202@RedHat.com> <D9CAEFBB-0B58-43FE-A346-4BDD4150DB92@oracle.com> <4ADC5DC8.90500@RedHat.com> <10B38617-8037-4CA1-AE90-13F378043E42@oracle.com> <4ADF6FA2.50801@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60795 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752752AbZJWRSw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Oct 2009 13:18:52 -0400
In-Reply-To: <4ADF6FA2.50801-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 21, 2009 at 04:31:30PM -0400, Steve Dickson wrote:
> On 10/21/2009 01:37 PM, Chuck Lever wrote:
> > That should be simple to implement by having nfs_nfs_version
> > leave *version set to zero if the defaultvers= option is rightmost, and
> > then have the new logic you added in nfs_validate_options() additionally
> > strip off defaultvers= before going ahead with the mount attempts.
> > 
> > Does that make sense?
> Yes. but you are assuming defaultvers is a valid mount option and it is
> not. So when/if it does, we can have this discussion then... Plus
> what we have today works just fine and if we want to do tweaks like this 
> later on, so be it... 

It may be hard to change the meaning of "defaultvers" (or whatever) once
it's in use.

--b.
