Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:27545 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758290Ab0ENRzF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 May 2010 13:55:05 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <D74F260C-E7BE-436B-BBC2-6DFFB02FA0C1@netapp.com>
From: Andy Adamson <andros@netapp.com>
To: Jiri Kortus <sumix@atlas.cz>
In-Reply-To: <4BED89E2.8070903@atlas.cz>
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Subject: Re: IPv6 support in pNFS
Date: Fri, 14 May 2010 13:55:03 -0400
References: <4BED89E2.8070903@atlas.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi

The file layout client does not currently have the ability to store  
ipv6 addresses in the data server cache. So even though the data  
servers themselves support ipv6 (via a NFSv4.1 connection), and the  
GETDEVICEINFO for the file layout can communicate ipv6 addresses the  
pNFS file layout client will not use them. This is a feature that is  
on the 'B' list of pNFS features to implement.

-->Andy

On May 14, 2010, at 1:35 PM, Jiri Kortus wrote:

> Hi,
>
> I'm sorry to flood the mailing list by repeating my question several  
> times - I've already asked whether someone would be so kind as to  
> tell me something about the situation of IPv6 support in pNFS. Just  
> anything related to it would be appreciated very much since nobody  
> gave me an answer (except Boaz Harrosh who wrote me about the IPv6  
> absence in OSD target). I'd like to know whether there's any support  
> for IPv6 (concerning all of the layouts available), if yes what are  
> the issues with that, if not when the implementation is planned to  
> start etc. I did google that a lot before asking but haven't found  
> anything. Thanks very much in advance.
>
> Best regards,
>
> Jiri Kortus
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

