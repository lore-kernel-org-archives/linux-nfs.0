Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:15203 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756365Ab1LOR6o (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Dec 2011 12:58:44 -0500
Message-ID: <4EEA349E.8060800@redhat.com>
Date: Thu, 15 Dec 2011 12:55:42 -0500
From: Ric Wheeler <rwheeler@redhat.com>
MIME-Version: 1.0
To: "Loke, Chetan" <Chetan.Loke@netscout.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Al Viro <viro@ZenIV.linux.org.uk>, linux-scsi@vger.kernel.org,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Hannes Reinecke <hare@suse.de>,
        Andrew Morton <akpm@linux-foundation.org>, linux-nfs@vger.kernel.org,
        Joel Becker <jlbec@evilplan.org>,
        James Bottomley <James.Bottomley@HansenPartnership.com>
Subject: Re: copy offload support in Linux - new system call needed?
References: <4EE8F75F.6070800@gmail.com>  <20111214192739.GN2203@ZenIV.linux.org.uk> <4EE8FC2E.3010207@gmail.com>  <20111214222723.GD7623@fieldses.org>  <1323961140.14317.2.camel@lade.trondhjem.org>  <D3F292ADF945FB49B35E96C94C2061B91516E391@nsmail.netscout.com>  <1323965498.14317.13.camel@lade.trondhjem.org>  <D3F292ADF945FB49B35E96C94C2061B91516E3FC@nsmail.netscout.com> <1323968015.14317.28.camel@lade.trondhjem.org> <4EEA2BF7.5030107@gmail.com> <D3F292ADF945FB49B35E96C94C2061B91516E489@nsmail.netscout.com>
In-Reply-To: <D3F292ADF945FB49B35E96C94C2061B91516E489@nsmail.netscout.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/15/2011 12:31 PM, Loke, Chetan wrote:
>> I think that hypervisor vendors will be very interested in this feature
>> which
>> would explain why vmware was active in drafting both the NFS and T10
> Specs are the only way to convince storage-target-vendors ;). Otherwise target-stack will need to implement multiple custom-CDB-handlers for different front-end APIs(which is ugly).
>
>
> Chetan

Hi Chetan,

I should post from my "Red Hat" email to make this less confusing for you - I 
know that this is in fact interesting to vendors :)

Thanks!

Ric

