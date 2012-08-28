Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:62672 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751686Ab2H1SBS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Aug 2012 14:01:18 -0400
Received: by ialo24 with SMTP id o24so11222123ial.19
        for <linux-nfs@vger.kernel.org>; Tue, 28 Aug 2012 11:01:17 -0700 (PDT)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 6.0 \(1486\))
Subject: Re: kernel BUG at fs/nfs/idmap.c:684!
From: Frank Nicholas <frank@nicholasfamilycentral.com>
In-Reply-To: <CDF28CCA-4DFC-4CF7-880A-49E795E3389E@nicholasfamilycentral.com>
Date: Tue, 28 Aug 2012 14:01:15 -0400
Cc: Bryan Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org,
        "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>
Message-Id: <C9C62063-74C8-4B58-98B1-E2ED28FC63D1@nicholasfamilycentral.com>
References: <DE540E0D-0D1E-45CE-9968-DA9950497B07@nicholasfamilycentral.com> <0DDD46E4-9D32-4BA4-8BD8-22F347FC9E9B@nicholasfamilycentral.com> <503CD925.7050000@netapp.com> <F5B43205-C11E-4ED7-A530-DCE49B911BE6@nicholasfamilycentral.com> <20120828174314.GA2202@umich.edu> <CDF28CCA-4DFC-4CF7-880A-49E795E3389E@nicholasfamilycentral.com>
To: Jim Rees <rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Aug 28, 2012, at 1:46 PM, Frank Nicholas <frank@nicholasfamilycentral.com> wrote:

> 
> On Aug 28, 2012, at 1:43 PM, Jim Rees <rees@umich.edu> wrote:
> 
>> Frank Nicholas wrote:
>> 
>> Thanks for the quick reply.
>> 
>> The patches applied cleanly.  I've rebuilt my kernel.  The reboot will
>> have to wait until I have physical access to the machine to do a hard
>> power off…  Unless you know of some way to clean up the hung NFS items so
>> I can do a reboot.  Currently if I try a 'shutdown -r now', the system
>> hangs on trying to clean up the NFS items.
>> 
>> Did you try "reboot -f"?
> 
> 
> Yep - Remembering back to the old Solaris days, 'sync ; sync ; sync ; reboot -f'.
> 
> That got it.  The 'emerge --sync' ran fine & the VM's that are using stores from NFS shares are working ok.  So far no NFS issues.  
> 
> Thanks.
> 

After the reboot, doing an 'emerge --sync' & starting a VM, I have the following in my syslog:

Aug 28 13:52:09 martin rpc.idmapd[2899]: nfscb: write(/var/lib/nfs/rpc_pipefs//nfs/clnt0/idmap): No space left on device
Aug 28 13:52:19 martin rpc.idmapd[2899]: nfscb: write(/var/lib/nfs/rpc_pipefs//nfs/clnt0/idmap): No space left on device
Aug 28 13:52:19 martin rpc.idmapd[2899]: nfscb: write(/var/lib/nfs/rpc_pipefs//nfs/clnt0/idmap): No space left on device
Aug 28 13:52:19 martin rpc.idmapd[2899]: nfscb: write(/var/lib/nfs/rpc_pipefs//nfs/clnt0/idmap): No space left on device
Aug 28 13:52:19 martin rpc.idmapd[2899]: nfscb: write(/var/lib/nfs/rpc_pipefs//nfs/clnt0/idmap): No space left on device
Aug 28 13:52:19 martin rpc.idmapd[2899]: nfscb: write(/var/lib/nfs/rpc_pipefs//nfs/clnt0/idmap): No space left on device
Aug 28 13:52:19 martin rpc.idmapd[2899]: nfscb: write(/var/lib/nfs/rpc_pipefs//nfs/clnt0/idmap): No space left on device
Aug 28 13:52:19 martin rpc.idmapd[2899]: nfscb: write(/var/lib/nfs/rpc_pipefs//nfs/clnt0/idmap): No space left on device
Aug 28 13:54:05 martin rpc.idmapd[2899]: nfscb: write(/var/lib/nfs/rpc_pipefs//nfs/clnt0/idmap): No space left on device
Aug 28 13:54:05 martin rpc.idmapd[2899]: nfscb: write(/var/lib/nfs/rpc_pipefs//nfs/clnt0/idmap): No space left on device
Aug 28 13:54:05 martin rpc.idmapd[2899]: nfscb: write(/var/lib/nfs/rpc_pipefs//nfs/clnt0/idmap): No space left on device
Aug 28 13:54:05 martin rpc.idmapd[2899]: nfscb: write(/var/lib/nfs/rpc_pipefs//nfs/clnt0/idmap): No space left on device
Aug 28 13:54:05 martin rpc.idmapd[2899]: nfscb: write(/var/lib/nfs/rpc_pipefs//nfs/clnt0/idmap): No space left on device
Aug 28 13:54:05 martin rpc.idmapd[2899]: nfscb: write(/var/lib/nfs/rpc_pipefs//nfs/clnt0/idmap): No space left on device

I believe each group of these (by date/time) were when I did the 'emerge --sync' & when I started the VM who has a virtual drive on an NFS share.  I don't remember seeing anything like this before.  Is this due to the patch?  Should I be concerned?  I know this is a pipe, but I've confirmed there is plenty of free disk space everywhere.  The pipe does exist on the file system.  There is plenty of free memory.  Any suggestions?

Thanks.