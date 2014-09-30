Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:16380 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751166AbaI3Pyt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Sep 2014 11:54:49 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s8UFsmfk019090
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Tue, 30 Sep 2014 11:54:48 -0400
Message-ID: <542AD247.3040701@RedHat.com>
Date: Tue, 30 Sep 2014 11:54:47 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Simo Sorce <simo@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/1] Move the wants only to the auth unit.
References: <1412014923-26587-1-git-send-email-simo@redhat.com>	<1412014923-26587-2-git-send-email-simo@redhat.com>	<542AC6AA.1090702@RedHat.com> <20140930113115.72fc400c@willson.usersys.redhat.com>
In-Reply-To: <20140930113115.72fc400c@willson.usersys.redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 09/30/2014 11:31 AM, Simo Sorce wrote:
> On Tue, 30 Sep 2014 11:05:14 -0400
> Steve Dickson <SteveD@redhat.com> wrote:
> 
>> On 09/29/2014 02:22 PM, Simo Sorce wrote:
>>> This way either gssproxy or rpc.svcgssd are started only if the
>>> auth module is requested, and it finds a keytab.
>>> If the wants are in the main nfs-client or nfs-server unit files
>>> then the two deamons are started unconditionally and would require
>>> conditions which we can test once and for all in a single unit file
>>> instead.
>>>
>>> Signed-off-by: Simo Sorce <simo@redhat.com>
>>> ---
>>>  systemd/auth-rpcgss-module.service | 3 ++-
>>>  systemd/nfs-client.target          | 4 ++--
>>>  systemd/nfs-server.service         | 1 -
>>>  3 files changed, 4 insertions(+), 4 deletions(-)
>>>
>>> diff --git a/systemd/auth-rpcgss-module.service
>>> b/systemd/auth-rpcgss-module.service index
>>> 3fc2f4ac924f7e9d6e24969bb9a21d88a5c144fc..0355e13e009528632e97373332db9fa3acdfd1a9
>>> 100644 --- a/systemd/auth-rpcgss-module.service +++
>>> b/systemd/auth-rpcgss-module.service @@ -6,7 +6,8 @@
>>>  # unit will fail.  But that's OK.)
>>>  [Unit]
>>>  Description=Kernel Module supporting RPCSEC_GSS
>>> -Before=gssproxy.service rpc-svcgssd.service
>>> +Before=gssproxy.service rpc-svcgssd.service rpc-gssd.service
>> By moving these into this unit,it destroys client/server
>> sync starts commit 12a95eda talks about... 
> 
> No it does not, this before is critical, the kernel module must be
> loaded before the gss daemons are started.
Understood.... but both the nfs-server.service and nfs-client.target
units have a Wants=auth-rpcgss-module.service, is not clear unit
will get started first... On one of my very fast booting machines
this race caused ordering cycles in systemd... I think... at least
when I ordered the server to start then the client the cycles
went a way... but who knows... 

> 
>> Maybe we could put an After=nfs-server.service in nfs-client.target
> 
> Why would you load the auth modules *after* nfs client and servers are
> started ?
> I think this could cause race conditions at mount on boot if someone
> wants to mount a filesystem with sec=krb5
Again it has nothing to do the loading of the module... You are
correct the they have to be loaded before the gss daemons are started.
Its all about the ordering of the server and client units.

> 
>> to bring back that synchronization... because in the end
>> we really really want the server to start first especially
>> when gssproxy is involved and both units are enabled.
> 
> uh ?
> no you really want to start the auth damoens first, if the server
> starts first then a mount request from a client could race with
> gssproxy starting up and poking the proc file to enable use of gssproxy
> resulting in the auth module to permanently initialize to use the old
> interface.
My bad on this one... I was thinking about when the nfs-client.target 
was not starting gssproxy... there was race with the server which
caused both gssproxy and rpc.svcgssd to be started. Now that the 
client is starting gssproxy, that race no longer exists...

> 
>> Also, this will cause gssproxy to be started on every boot
>> regardless whether Kerberos is installed and configured
>> (which not the case with rpc.svcgssd)... 
> 
> This is a separate issue, I am trying to get the ordering right here,
> then we can debug why gssproxy is started, I suspect Wants always kicks
> in regrardless of ConditionPathExists.
> 
>> I can hear the complaints already... Why is NFS starting 
>> up this daemon that will never have anything to do, in
>> the case when Kerberos is not installed/configure
>> which could be the majority of the cases...
>>
>> I would really really, really like to avoid this.
> 
> We can handle it in the next patch. Let's get the order right first.
Fine...

steved.

> 
> Simo.
> 
> 
> 
