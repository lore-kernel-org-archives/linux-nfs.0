Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16751 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752169Ab1AYRFk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Jan 2011 12:05:40 -0500
Message-ID: <4D3F02DD.6000606@RedHat.com>
Date: Tue, 25 Jan 2011 12:05:33 -0500
From: Steve Dickson <SteveD@redhat.com>
To: Thomas Haynes <thomas@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: Patched up cthon source?
References: <E5AAF04F-8A0E-4506-A29D-A0CD4098AA64@netapp.com>
In-Reply-To: <E5AAF04F-8A0E-4506-A29D-A0CD4098AA64@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I just set up a git tree on linux-nfs.org 

    git://linux-nfs.org/~steved/cthon04.git

I'll start applying the patches to that tree so we all
will have one common place to pull from... At least for now...

steved.


On 01/24/2011 05:19 PM, Thomas Haynes wrote:
> I'm being evil here on purpose. :->
> 
> I'm trying to run cthon04 as downloaded from the connectathon.org repository
> and I'm getting this:
> 
> 
> Nroff
> ./stat: no data in nroff.time
> general tests failed
> Tests failed, leaving /cthon04/loghyr mounted
> 
> 
> As I kinda recall several people fixing this already, where would I go to get patches?--
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
