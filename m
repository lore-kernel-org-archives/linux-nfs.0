From: Jiri Kortus <sumix-a4qEbw8STSk@public.gmane.org>
Subject: Re: IPv6 support in pNFS
Date: Sun, 16 May 2010 15:42:31 +0200
Message-ID: <4BEFF647.7@atlas.cz>
References: <4BED89E2.8070903@atlas.cz> <D74F260C-E7BE-436B-BBC2-6DFFB02FA0C1@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Andy Adamson <andros@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from minas.ics.muni.cz ([147.251.4.40]:50733 "EHLO minas.ics.muni.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753405Ab0EPNnK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 16 May 2010 09:43:10 -0400
In-Reply-To: <D74F260C-E7BE-436B-BBC2-6DFFB02FA0C1@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks very much both to you and to Chuck Lever for providing some 
information about it!

Best regards,

Jiri


Dne 14.5.2010 19:55, Andy Adamson napsal(a):
> Hi
>
> The file layout client does not currently have the ability to store 
> ipv6 addresses in the data server cache. So even though the data 
> servers themselves support ipv6 (via a NFSv4.1 connection), and the 
> GETDEVICEINFO for the file layout can communicate ipv6 addresses the 
> pNFS file layout client will not use them. This is a feature that is 
> on the 'B' list of pNFS features to implement.
>
> -->Andy
>
> On May 14, 2010, at 1:35 PM, Jiri Kortus wrote:
>
>> Hi,
>>
>> I'm sorry to flood the mailing list by repeating my question several 
>> times - I've already asked whether someone would be so kind as to 
>> tell me something about the situation of IPv6 support in pNFS. Just 
>> anything related to it would be appreciated very much since nobody 
>> gave me an answer (except Boaz Harrosh who wrote me about the IPv6 
>> absence in OSD target). I'd like to know whether there's any support 
>> for IPv6 (concerning all of the layouts available), if yes what are 
>> the issues with that, if not when the implementation is planned to 
>> start etc. I did google that a lot before asking but haven't found 
>> anything. Thanks very much in advance.
>>
>> Best regards,
>>
>> Jiri Kortus
>> -- 
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> -- 
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

