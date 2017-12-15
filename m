Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56778 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755474AbdLOS00 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 15 Dec 2017 13:26:26 -0500
Subject: Re: [systemd-devel] [PATCH][V2] rpcbind.service: Not pulling the
 rpcbind.target
To: Lennart Poettering <lennart@poettering.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Systemd Mailing List <systemd-devel@lists.freedesktop.org>
References: <20171215130047.8944-1-steved@redhat.com>
 <20171215145203.GA16686@gardel-login>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <424bca50-cba3-7744-c59b-07e191e1963f@RedHat.com>
Date: Fri, 15 Dec 2017 13:26:25 -0500
MIME-Version: 1.0
In-Reply-To: <20171215145203.GA16686@gardel-login>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/15/2017 09:52 AM, Lennart Poettering wrote:
> On Fr, 15.12.17 08:00, Steve Dickson (steved@redhat.com) wrote:
> 
>> According to systemd.special(7) manpage:
>>
>> rpcbind.target
>>     The portmapper/rpcbind pulls in this target and orders itself
>>     before it, to indicate its availability. systemd automatically
>>     adds dependencies of type After= for this target unit to
>>     all SysV init script service units with an LSB header
>>     referring to the "$portmap" facility.
>>
>> Signed-off-by: Steve Dickson <steved@redhat.com>
>> Fixes: https://bugzilla.redhat.com/show_bug.cgi?id=1431574
>> ---
>>  systemd/rpcbind.service.in | 4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/systemd/rpcbind.service.in b/systemd/rpcbind.service.in
>> index f8cfa9f..9dbc82c 100644
>> --- a/systemd/rpcbind.service.in
>> +++ b/systemd/rpcbind.service.in
>> @@ -6,8 +6,8 @@ RequiresMountsFor=@statedir@
>>  
>>  # Make sure we use the IP addresses listed for
>>  # rpcbind.socket, no matter how this unit is started.
>> -Wants=rpcbind.socket
>> -After=rpcbind.socket
>> +Requires=rpcbind.socket
>> +Before=rpcbind.target
> 
> You should still pull in rpcbind.target as the man page
> says. i.e. "Wants=rpcbind.target" really should be there.
Duly noted... and changed!

thanks!

steved.
> 
> Lennart
> 
