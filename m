Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:22978 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932270Ab3DBTUn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Apr 2013 15:20:43 -0400
Message-ID: <515B2F8D.3030302@RedHat.com>
Date: Tue, 02 Apr 2013 15:20:45 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Simo Sorce <simo@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/3] Avoid reverse resolution for server name
References: <1364924947-16985-1-git-send-email-simo@redhat.com> <1364924947-16985-3-git-send-email-simo@redhat.com> <4FA345DA4F4AE44899BD2B03EEEC2FA9286FB37F@SACEXCMBX04-PRD.hq.netapp.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9286FB37F@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/04/13 13:58, Myklebust, Trond wrote:
>> -----Original Message-----
>> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
>> owner@vger.kernel.org] On Behalf Of Simo Sorce
>> Sent: Tuesday, April 02, 2013 1:49 PM
>> To: Linux NFS Mailing list
>> Subject: [PATCH 2/3] Avoid reverse resolution for server name
>>
>> A NFS client should be able to work properly even if the DNS Reverse record
>> for the server is not set. There is no excuse to forcefully prevent that from
>> working when it can.
> 
> Note that rpc.statd has the same limitation.
> 
>> This patch adds a new -N option that takes an 'on' or 'off' argument and
>> controls whether forced PTR resolution is avoided (on) or performed (off)
> 
> '-N' already has a very different meaning on rpc.mountd and rpc.nfsd. It might therefore be better to choose a different name to avoid confusion.
> Also, why do a single option with an 'on/off' argument instead of just choosing 2 options ?
Do we really what two options? why not just have something like -Z that will restore today default?

steved.

>  
>  Trond
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
