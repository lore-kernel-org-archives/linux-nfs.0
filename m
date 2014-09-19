Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:28532 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756755AbaISQbU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Sep 2014 12:31:20 -0400
Message-ID: <541C5A55.7010403@RedHat.com>
Date: Fri, 19 Sep 2014 12:31:17 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Simo Sorce <simo@redhat.com>
Subject: Re: [PATCH 0/2] Use the gssproxy damon for GSSAPI credentials
References: <1411131103-17254-1-git-send-email-steved@redhat.com> <20140919155733.GA16658@fieldses.org>
In-Reply-To: <20140919155733.GA16658@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 09/19/2014 11:57 AM, J. Bruce Fields wrote:
> On Fri, Sep 19, 2014 at 08:51:41AM -0400, Steve Dickson wrote:
>> The gssproxy(8) daemon is now how the managing of GSSAPI 
>> credentials should be done. 
>>
>> These to patches has the nfs-server systemd script start 
>> gssproxy instead of rpc.svcgssd and removes the building 
>> and installation of rpc.svcgssd.
>>
>> For now I'm leaving the source files... Just in case... ;-)
> 
> If nothing else, we'd like to keep support for older kernels for a
> while.
Good point... I should probably make this a configurable...
something like --enable_svcgssd and have it off by default...

steved.

> 
> --b.
> 
>>
>> Steve Dickson (2):
>>   nfs-server: Replace rpc.svcgssd with gssproxy
>>   svcgssd: Remove rules from the Makefile.am
>>
>>  systemd/nfs-server.service  |  4 ++--
>>  systemd/rpc-svcgssd.service | 19 -------------------
>>  utils/gssd/Makefile.am      | 25 ++-----------------------
>>  3 files changed, 4 insertions(+), 44 deletions(-)
>>  delete mode 100644 systemd/rpc-svcgssd.service
>>
>> -- 
>> 1.9.3
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
