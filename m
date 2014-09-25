Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bl2on0148.outbound.protection.outlook.com ([65.55.169.148]:51093
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753487AbaIYRwX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Sep 2014 13:52:23 -0400
Message-ID: <54245661.8010107@eas.gatech.edu>
Date: Thu, 25 Sep 2014 13:52:33 -0400
From: MJ Jenkins <mack.jenkins@eas.gatech.edu>
MIME-Version: 1.0
To: Emmanuel Florac <eflorac@intellique.com>
CC: <linux-nfs@vger.kernel.org>
Subject: Re: NFS Share To OS X
References: <5424156C.8080602@eas.gatech.edu> <20140925183034.432731eb@harpe.intellique.com>
In-Reply-To: <20140925183034.432731eb@harpe.intellique.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is the /etc/exports file.  129.169 is the Mac I'm exporting to.  
129.183 is the other RHEL machine.

##### Mount point for Britney Schmidt's Mac Pro #####
/nfs/bsmac 
192.168.129.169(rw,all_squash,no_subtree_check,insecure,anonuid=0) 
192.168.129.183(rw,no_root_squash,no_subtree_chck)


This is /etc/fstab from the Mac.
#storage:/nfs/bsmac       /data1          nfs 
resvport,nolocks,locallocks,intr,soft,wsize=32768,rsize=3276
storage:/nfs/bsmac        /data1          nfs 
vers=3,noowners,nolocks,nolockd,nolock,nonlm,automounted,nosuid,hard,bg,noresvport,intr,rw,tcp,nfc

That 1st line in /etc/fstab is another way I was mounting the share 
trying to solve this one.

Thanks for any assistance that can be provided.

Mack

On 09/25/2014 12:30 PM, Emmanuel Florac wrote:
> Le Thu, 25 Sep 2014 09:15:24 -0400
> MJ Jenkins <mack.jenkins@eas.gatech.edu> écrivait:
>
>> The problem comes in when the user on the Mac writes files to the NFS
>> share.  On the RHEL side the files are owned by user root and group
>> nfsnobody.  Has anyone else run into this issue?  I'm not sure if the
>> issue is how I am exporting the share to the Mac, or how I have the
>> share mounted on the Mac.
> Without the content of your /etc/exports, it's impossible to know
> what's happening. Mac behave like regular NFS clients. Maybe you have
> "all_squash,anonuid=0,anongid=5" in your export parameter, maybe it's
> something else entirely.
>

