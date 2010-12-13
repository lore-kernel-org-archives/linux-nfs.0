Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:57316 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753296Ab0LMTEr convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Dec 2010 14:04:47 -0500
Subject: Re: Side effects of having NFSv4 mounted over udp
Content-Type: text/plain; charset=us-ascii
From: Thomas Haynes <thomas@netapp.com>
In-Reply-To: <4D05CF50.1010305@cea.fr>
Date: Mon, 13 Dec 2010 13:04:28 -0600
Cc: linux-nfs@vger.kernel.org
Message-Id: <A9F12BB4-8571-4C58-AC6A-8094FA912B27@netapp.com>
References: <4D05CF50.1010305@cea.fr>
To: DENIEL Philippe <philippe.deniel@cea.fr>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Dec 13, 2010, at 1:46 AM, DENIEL Philippe wrote:

> Hi,
> 
> I know NFSv4 is definitely a connection oriented protocol, but noting prevent from using "mount -t nfs4 -o proto=udp <...>". Using TCP instead of UDP could be of great interest, especially in a HPC context where thousands of clients will operate at the same time. If a nfs mount point is made over udp, what would be the side effects ? I tried to run the connectathon on such a udp based mount point and I could find no errors. Is NFSv4/UDP a suitable solution ? Or does it make no sense to use udp ?


You might find that some implementations have UDP disabled and it might then make
it hard to triage what is going on.

I believe both NetApp's OnTap and Oracle's Solaris have it turned off.


> 
> Thanks in advance for your answer.
> 
>   Regards
> 
>      Philippe
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

