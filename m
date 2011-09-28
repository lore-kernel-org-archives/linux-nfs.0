Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:46789 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756025Ab1I1XDD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Sep 2011 19:03:03 -0400
Received: from public by plane.gmane.org with local (Exim 4.69)
	(envelope-from <public@plane.gmane.org>)
	id 1R939Y-00019S-Cq
	for linux-nfs@vger.kernel.org; Thu, 29 Sep 2011 01:03:00 +0200
Message-ID: <4E83A799.1090303@linux.vnet.ibm.com>
Date: Wed, 28 Sep 2011 16:02:49 -0700
From: Venkateswararao Jujjuri <jvrao@linux.vnet.ibm.com>
To: Sreeram B S
	<public-sreeramb-HgOvQuBEEgTQT0dZR+AlfA@plane.gmane.org>
CC: public-linux-nfs-u79uwXL29TY76Z2rM5mHXA@plane.gmane.org
Subject: Re: NFS mounts and its propagation
References: <4E805C16.4030509@netapp.com>
In-Reply-To: <4E805C16.4030509@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 09/26/2011 04:03 AM, Sreeram B S wrote:
> Hi,
> I am Sreeram. This question is related to NFS.
> I have a typical scenario. Please assume that there are 3 machines M1,
> M2, M3. Each of them are having directories /tmp/abc in them. All the
> NFS permissions are set appropriately.
> Now, a user mounts M2's /tmp/abc on M1's /tmp/abc by issuing mount
> command on M1. Mount is successful.
> Then the user mounts M3's /tmp/abc on M2's /tmp/abc by issuing mount
> command on M2. Mount successful.
> Now I would expect the contents of M3's /tmp/abc to be shown as output
> of 'ls' issue on M1. But this is not happening. I am unable to
> comprehend the reason. Could you please guide me?

What are you seeing instead? Are you seeing M2's contents on M1?
Did you try to change the order of the experiment? i.e First mount M3 on 
M2 and then mount M2 on M1? Just curious to see if there is any change 
in the behavior.

Thanks,
JV

>
> According to me, the contents of M3 should have shown up in M1's 'ls'
> command, because the /tmp/abc of M1 is nothing but a *live* reflection
> of /tmp/abc of M2. So whatever changes are done to M2's /tmp/abc should
> be reflected on M1. Here, M2's /tmp/abc is mounting M3's /tmp/abc and so
> this change should be reflected on M1's /tmp/abc as well. But this isn't
> happening.
>
> Kindly suggest if I am incorrect in my understanding or usage.
> The command I am using is:
>
> On M1: mount -t nfs M2:/tmp/abc /tmp/abc
> On M2: mount -t nfs M3:/tmp/abc /tmp/abc
>
> Regards,
> Sreeram
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at http://vger.kernel.org/majordomo-info.html
>


