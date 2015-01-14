Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:33368 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751159AbbANN0e (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Jan 2015 08:26:34 -0500
Message-ID: <54B66E88.2040908@RedHat.com>
Date: Wed, 14 Jan 2015 08:26:32 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Michal Sekletar <msekleta@redhat.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Systemd Mailing List <systemd-devel@lists.freedesktop.org>
Subject: Re: [systemd-devel] [PATCH 1/3] systemd: Bind rpc.idmapd to the nfs-server
 service
References: <1421181457-8159-1-git-send-email-steved@redhat.com> <1421181457-8159-2-git-send-email-steved@redhat.com> <20150114094637.GA26499@morgoth.brq.redhat.com>
In-Reply-To: <20150114094637.GA26499@morgoth.brq.redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/14/2015 04:46 AM, Michal Sekletar wrote:
> On Tue, Jan 13, 2015 at 03:37:35PM -0500, Steve Dickson wrote:
>> Since rpc.idmapd is only used by the nfs server, to do 
>> its id mapping, bind the nfs-idmapd service to the 
>> nfs-server service so rpc.idmapd will be started 
>> and stopped with the nfs server.
>>
>> Signed-off-by: Steve Dickson <steved@redhat.com>
>> ---
>>  systemd/nfs-idmapd.service | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/systemd/nfs-idmapd.service b/systemd/nfs-idmapd.service
>> index 11895e2..61c9a64 100644
>> --- a/systemd/nfs-idmapd.service
>> +++ b/systemd/nfs-idmapd.service
>> @@ -1,7 +1,7 @@
>>  [Unit]
>>  Description=NFSv4 ID-name mapping service
>>  
>> -PartOf=nfs-utils.service
>> +BindTo=nfs-server.service
> 
> Please note that actual name of the dependency is "BindsTo".
Got it.. Thanks!

steved.

> 
> Michal
> 
>>  
>>  Wants=nfs-config.service
>>  After=nfs-config.service
>> -- 
>> 2.1.0
>>
>> _______________________________________________
>> systemd-devel mailing list
>> systemd-devel@lists.freedesktop.org
>> http://lists.freedesktop.org/mailman/listinfo/systemd-devel
