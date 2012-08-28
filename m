Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:9727 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751691Ab2H1SIR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Aug 2012 14:08:17 -0400
Message-ID: <503D090E.3060505@netapp.com>
Date: Tue, 28 Aug 2012 14:08:14 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Frank Nicholas <frank@nicholasfamilycentral.com>,
        Jim Rees <rees@umich.edu>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "bfields@fieldses.org" <bfields@fieldses.org>
Subject: Re: kernel BUG at fs/nfs/idmap.c:684!
References: <DE540E0D-0D1E-45CE-9968-DA9950497B07@nicholasfamilycentral.com>  <0DDD46E4-9D32-4BA4-8BD8-22F347FC9E9B@nicholasfamilycentral.com>  <503CD925.7050000@netapp.com>  <F5B43205-C11E-4ED7-A530-DCE49B911BE6@nicholasfamilycentral.com>  <20120828174314.GA2202@umich.edu>  <CDF28CCA-4DFC-4CF7-880A-49E795E3389E@nicholasfamilycentral.com>  <C9C62063-74C8-4B58-98B1-E2ED28FC63D1@nicholasfamilycentral.com> <4FA345DA4F4AE44899BD2B03EEEC2FA908F755A3@SACEXCMBX04-PRD.hq.netapp.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA908F755A3@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/28/2012 02:06 PM, Myklebust, Trond wrote:
> On Tue, 2012-08-28 at 14:01 -0400, Frank Nicholas wrote:
>> On Aug 28, 2012, at 1:46 PM, Frank Nicholas <frank@nicholasfamilycentral.com> wrote:
>>
>>>
>>> On Aug 28, 2012, at 1:43 PM, Jim Rees <rees@umich.edu> wrote:
>>>
>>>> Frank Nicholas wrote:
>>>>
>>>> Thanks for the quick reply.
>>>>
>>>> The patches applied cleanly.  I've rebuilt my kernel.  The reboot will
>>>> have to wait until I have physical access to the machine to do a hard
>>>> power off…  Unless you know of some way to clean up the hung NFS items so
>>>> I can do a reboot.  Currently if I try a 'shutdown -r now', the system
>>>> hangs on trying to clean up the NFS items.
>>>>
>>>> Did you try "reboot -f"?
>>>
>>>
>>> Yep - Remembering back to the old Solaris days, 'sync ; sync ; sync ; reboot -f'.
>>>
>>> That got it.  The 'emerge --sync' ran fine & the VM's that are using stores from NFS shares are working ok.  So far no NFS issues.  
>>>
>>> Thanks.
>>>
>>
>> After the reboot, doing an 'emerge --sync' & starting a VM, I have the following in my syslog:
>>
>> Aug 28 13:52:09 martin rpc.idmapd[2899]: nfscb: write(/var/lib/nfs/rpc_pipefs//nfs/clnt0/idmap): No space left on device
>> Aug 28 13:52:19 martin rpc.idmapd[2899]: nfscb: write(/var/lib/nfs/rpc_pipefs//nfs/clnt0/idmap): No space left on device
>> Aug 28 13:52:19 martin rpc.idmapd[2899]: nfscb: write(/var/lib/nfs/rpc_pipefs//nfs/clnt0/idmap): No space left on device
>> Aug 28 13:52:19 martin rpc.idmapd[2899]: nfscb: write(/var/lib/nfs/rpc_pipefs//nfs/clnt0/idmap): No space left on device
>> Aug 28 13:52:19 martin rpc.idmapd[2899]: nfscb: write(/var/lib/nfs/rpc_pipefs//nfs/clnt0/idmap): No space left on device
>> Aug 28 13:52:19 martin rpc.idmapd[2899]: nfscb: write(/var/lib/nfs/rpc_pipefs//nfs/clnt0/idmap): No space left on device
>> Aug 28 13:52:19 martin rpc.idmapd[2899]: nfscb: write(/var/lib/nfs/rpc_pipefs//nfs/clnt0/idmap): No space left on device
>> Aug 28 13:52:19 martin rpc.idmapd[2899]: nfscb: write(/var/lib/nfs/rpc_pipefs//nfs/clnt0/idmap): No space left on device
>> Aug 28 13:54:05 martin rpc.idmapd[2899]: nfscb: write(/var/lib/nfs/rpc_pipefs//nfs/clnt0/idmap): No space left on device
>> Aug 28 13:54:05 martin rpc.idmapd[2899]: nfscb: write(/var/lib/nfs/rpc_pipefs//nfs/clnt0/idmap): No space left on device
>> Aug 28 13:54:05 martin rpc.idmapd[2899]: nfscb: write(/var/lib/nfs/rpc_pipefs//nfs/clnt0/idmap): No space left on device
>> Aug 28 13:54:05 martin rpc.idmapd[2899]: nfscb: write(/var/lib/nfs/rpc_pipefs//nfs/clnt0/idmap): No space left on device
>> Aug 28 13:54:05 martin rpc.idmapd[2899]: nfscb: write(/var/lib/nfs/rpc_pipefs//nfs/clnt0/idmap): No space left on device
>> Aug 28 13:54:05 martin rpc.idmapd[2899]: nfscb: write(/var/lib/nfs/rpc_pipefs//nfs/clnt0/idmap): No space left on device
>>
>> I believe each group of these (by date/time) were when I did the 'emerge --sync' & when I started the VM who has a virtual drive on an NFS share.  I don't remember seeing anything like this before.  Is this due to the patch?  Should I be concerned?  I know this is a pipe, but I've confirmed there is plenty of free disk space everywhere.  The pipe does exist on the file system.  There is plenty of free memory.  Any suggestions?
> 
> An early version of those patches did indeed cause problems such as the
> above. Are you sure that you applied the patches that actually went
> upstream in

No, I don't think he did.  I forgot you fixed up a few things, so I sent him the last copy I had.

- Bryan

> 
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git&a=commitdiff&h=c5066945b7ea346a11424dbeb7830b7d7d00c206
> and
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git&a=commitdiff&h=12dfd080556124088ed61a292184947711b46cbe
> 

