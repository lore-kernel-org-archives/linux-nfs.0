Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:3572 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752323Ab2H1SGP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Aug 2012 14:06:15 -0400
Message-ID: <503D0884.6080509@netapp.com>
Date: Tue, 28 Aug 2012 14:05:56 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: Frank Nicholas <frank@nicholasfamilycentral.com>
CC: Jim Rees <rees@umich.edu>, linux-nfs@vger.kernel.org,
        "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>
Subject: Re: kernel BUG at fs/nfs/idmap.c:684!
References: <DE540E0D-0D1E-45CE-9968-DA9950497B07@nicholasfamilycentral.com> <0DDD46E4-9D32-4BA4-8BD8-22F347FC9E9B@nicholasfamilycentral.com> <503CD925.7050000@netapp.com> <F5B43205-C11E-4ED7-A530-DCE49B911BE6@nicholasfamilycentral.com> <20120828174314.GA2202@umich.edu> <CDF28CCA-4DFC-4CF7-880A-49E795E3389E@nicholasfamilycentral.com> <C9C62063-74C8-4B58-98B1-E2ED28FC63D1@nicholasfamilycentral.com>
In-Reply-To: <C9C62063-74C8-4B58-98B1-E2ED28FC63D1@nicholasfamilycentral.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/28/2012 02:01 PM, Frank Nicholas wrote:
> On Aug 28, 2012, at 1:46 PM, Frank Nicholas <frank@nicholasfamilycentral.com> wrote:
> 
>>
>> On Aug 28, 2012, at 1:43 PM, Jim Rees <rees@umich.edu> wrote:
>>
>>> Frank Nicholas wrote:
>>>
>>> Thanks for the quick reply.
>>>
>>> The patches applied cleanly.  I've rebuilt my kernel.  The reboot will
>>> have to wait until I have physical access to the machine to do a hard
>>> power off…  Unless you know of some way to clean up the hung NFS items so
>>> I can do a reboot.  Currently if I try a 'shutdown -r now', the system
>>> hangs on trying to clean up the NFS items.
>>>
>>> Did you try "reboot -f"?
>>
>>
>> Yep - Remembering back to the old Solaris days, 'sync ; sync ; sync ; reboot -f'.
>>
>> That got it.  The 'emerge --sync' ran fine & the VM's that are using stores from NFS shares are working ok.  So far no NFS issues.  
>>
>> Thanks.
>>
> 
> After the reboot, doing an 'emerge --sync' & starting a VM, I have the following in my syslog:
> 
> Aug 28 13:52:09 martin rpc.idmapd[2899]: nfscb: write(/var/lib/nfs/rpc_pipefs//nfs/clnt0/idmap): No space left on device
> Aug 28 13:52:19 martin rpc.idmapd[2899]: nfscb: write(/var/lib/nfs/rpc_pipefs//nfs/clnt0/idmap): No space left on device
> Aug 28 13:52:19 martin rpc.idmapd[2899]: nfscb: write(/var/lib/nfs/rpc_pipefs//nfs/clnt0/idmap): No space left on device
> Aug 28 13:52:19 martin rpc.idmapd[2899]: nfscb: write(/var/lib/nfs/rpc_pipefs//nfs/clnt0/idmap): No space left on device
> Aug 28 13:52:19 martin rpc.idmapd[2899]: nfscb: write(/var/lib/nfs/rpc_pipefs//nfs/clnt0/idmap): No space left on device
> Aug 28 13:52:19 martin rpc.idmapd[2899]: nfscb: write(/var/lib/nfs/rpc_pipefs//nfs/clnt0/idmap): No space left on device
> Aug 28 13:52:19 martin rpc.idmapd[2899]: nfscb: write(/var/lib/nfs/rpc_pipefs//nfs/clnt0/idmap): No space left on device
> Aug 28 13:52:19 martin rpc.idmapd[2899]: nfscb: write(/var/lib/nfs/rpc_pipefs//nfs/clnt0/idmap): No space left on device
> Aug 28 13:54:05 martin rpc.idmapd[2899]: nfscb: write(/var/lib/nfs/rpc_pipefs//nfs/clnt0/idmap): No space left on device
> Aug 28 13:54:05 martin rpc.idmapd[2899]: nfscb: write(/var/lib/nfs/rpc_pipefs//nfs/clnt0/idmap): No space left on device
> Aug 28 13:54:05 martin rpc.idmapd[2899]: nfscb: write(/var/lib/nfs/rpc_pipefs//nfs/clnt0/idmap): No space left on device
> Aug 28 13:54:05 martin rpc.idmapd[2899]: nfscb: write(/var/lib/nfs/rpc_pipefs//nfs/clnt0/idmap): No space left on device
> Aug 28 13:54:05 martin rpc.idmapd[2899]: nfscb: write(/var/lib/nfs/rpc_pipefs//nfs/clnt0/idmap): No space left on device
> Aug 28 13:54:05 martin rpc.idmapd[2899]: nfscb: write(/var/lib/nfs/rpc_pipefs//nfs/clnt0/idmap): No space left on device
> 
> I believe each group of these (by date/time) were when I did the 'emerge --sync' & when I started the VM who has a virtual drive on an NFS share.  I don't remember seeing anything like this before.  Is this due to the patch?  Should I be concerned?  I know this is a pipe, but I've confirmed there is plenty of free disk space everywhere.  The pipe does exist on the file system.  There is plenty of free memory.  Any suggestions?
> 

Do you have rpc.idmapd running?  Alternatively, if you have keyutils installed you could configure /etc/request-key.conf following the instructions in `man 8 nfsidmap`.

- Bryan

> Thanks.
> 

