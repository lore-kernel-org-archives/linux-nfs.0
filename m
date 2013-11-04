Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:36821 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751659Ab3KDPkB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Nov 2013 10:40:01 -0500
Message-ID: <5277C006.1060003@RedHat.com>
Date: Mon, 04 Nov 2013 10:40:54 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Noam Meltzer <tsnoam@gmail.com>
CC: linux-nfs@vger.kernel.org, Simo Sorce <simo@redhat.com>
Subject: Re: rpc.idmapd plugin for sssd
References: <CADtAWjC5PWixao_aPuqSiPxPSqhwN8PShQf7Jctua9aqzjc_YA@mail.gmail.com>
In-Reply-To: <CADtAWjC5PWixao_aPuqSiPxPSqhwN8PShQf7Jctua9aqzjc_YA@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/11/13 06:50, Noam Meltzer wrote:
> Hello,
> 
> I was thinking of writing a plugin for rpc.idmapd which will retrieve
> the required information from SSSD (https://fedorahosted.org/sssd/)
What is the purpose of the plug in? And are you aware rpc.idmapd is
only used on the server these days... the nfsidmap command is used
by the client... 

> 
> Before doing so, I just wanted to make sure that no one here is aware
> of an existing plugin?
No, there is no plugins for rpc.idmapd....

steved.

> 
> Best regards,
> Noam Meltzer
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
